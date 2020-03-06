import UIKit
import Vision

final class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    var detectedFaces = [(observation: VNFaceObservation, blur: Bool)]()
    var inputImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(importPhoto))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(sharePhoto))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addBlurRects()
    }
    
    @objc func faceTapped(_ sender: UITapGestureRecognizer) {
        guard let vw = sender.view else { return }
        detectedFaces[vw.tag].blur = !detectedFaces[vw.tag].blur
        renderBlurredFaces()
    }
    
    @objc func importPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func sharePhoto() {
        guard let img = imageView.image else { return }
        let ac = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        present(ac, animated: true)
    }
    
    func addBlurRects() {
        imageView.subviews.forEach { $0.removeFromSuperview() }
        
        let imageRect = imageView.contentClippingRect
        
        for (index, face) in detectedFaces.enumerated() {
            let boundingBox = face.observation.boundingBox
            
            let size = CGSize(width: boundingBox.width * imageRect.width, height: boundingBox.height * imageRect.height)
            
            var origin = CGPoint(x: boundingBox.minX * imageRect.width, y: (1 - face.observation.boundingBox.minY) * imageRect.height - size.height)
            
            origin.y  += imageRect.minY
            
            let vw = UIView(frame: CGRect(origin: origin, size: size))
            
            vw.tag = index
            vw.layer.borderColor = UIColor.red.cgColor
            vw.layer.borderWidth = 2
            imageView.addSubview(vw)
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(faceTapped))
            vw.addGestureRecognizer(recognizer)
        }
    }
    
    func detectFaces() {
        guard let inputImage = inputImage else { return }
        guard let ciImage = CIImage(image: inputImage) else { return }
        
        let request = VNDetectFaceRectanglesRequest { [unowned self] request, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let observations = request.results as? [VNFaceObservation] else { return }
                self.detectedFaces = Array(zip(observations, [Bool](repeating: false, count: observations.count)))
                self.addBlurRects()
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func renderBlurredFaces() {
        guard let currentUIImage = inputImage,
            let currentCGImage = currentUIImage.cgImage else { return }
        let currentCIImage = CIImage(cgImage: currentCGImage)
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(12, forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return }
        let blurredImage = UIImage(ciImage: outputImage)
        
        let renderer = UIGraphicsImageRenderer(size: currentUIImage.size)
        let result = renderer.image { ctx in
            currentUIImage.draw(at: .zero)
            let path = UIBezierPath()
            
            for face in detectedFaces {
                if face.blur {
                    let boundingBox = face.observation.boundingBox
                    let size = CGSize(width: boundingBox.width * currentUIImage.size.width, height: boundingBox.height * currentUIImage.size.height)
                    let origin = CGPoint(x: boundingBox.minX * currentUIImage.size.width, y: (1 - face.observation.boundingBox.minY) * currentUIImage.size.height - size.height)
                    let rect = CGRect(origin: origin, size: size)
                    let miniPath = UIBezierPath(rect: rect)
                    path.append(miniPath)
                }
            }
            
            if !path.isEmpty {
                path.addClip()
                blurredImage.draw(at: .zero)
            }
        }
        
        imageView.image = result
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        imageView.image = image
        inputImage = image
        
        dismiss(animated: true)
        detectFaces()
    }
}

extension ViewController: UINavigationControllerDelegate {
    
}
