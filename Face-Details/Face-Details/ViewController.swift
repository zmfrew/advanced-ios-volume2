import UIKit
import Vision

class ViewController: UIViewController {
    var imageView: UIImageView?
    
    override func loadView() {
        super.loadView()
        imageView = UIImageView()
        imageView?.contentMode = .scaleAspectFit
        view = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image = UIImage(named: "pic.jpg"),
            let cgImage = image.cgImage else { return }
        
        imageView?.image = image
        
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            if let observations = request.results as? [VNFaceObservation] {
                DispatchQueue.main.async {
                    self?.render(image, with: observations)
                }
            } else {
                print(error?.localizedDescription ?? "No observations found.")
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        DispatchQueue.global().async {
            do {
                try handler.perform([request])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func render(_ image: UIImage, with faceObservations: [VNFaceObservation]) {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        imageView?.image = renderer.image { ctx in
            image.draw(at: .zero)
            
            UIColor.red.set()
            ctx.cgContext.setLineWidth(2)
            ctx.cgContext.translateBy(x: 0, y: image.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            for face in faceObservations {
                let boundingRect = face.boundingBox
                let faceX = boundingRect.minX * image.size.width
                let faceY = boundingRect.minY * image.size.height
                let faceWidth = boundingRect.width * image.size.width
                let faceHeight = boundingRect.width * image.size.height
                
                let features = [
                    face.landmarks?.faceContour,
                    face.landmarks?.leftEye,
                    face.landmarks?.leftEyebrow,
                    face.landmarks?.leftPupil,
                    face.landmarks?.innerLips,
                    face.landmarks?.nose,
                    face.landmarks?.outerLips,
                    face.landmarks?.rightEye,
                    face.landmarks?.rightEyebrow,
                    face.landmarks?.rightPupil
                ]
                
                for case let feature? in features {
                    var points = [CGPoint]()
                    
                    for value in feature.normalizedPoints {
                        let xPos = faceX + CGFloat(value.x) * faceWidth
                        let yPos = faceY + CGFloat(value.y) * faceHeight
                        points.append(CGPoint(x: xPos, y: yPos))
                    }
                    
                    ctx.cgContext.addLines(between: points)
                    ctx.cgContext.strokePath()
                }
            }
        }
    }
}
