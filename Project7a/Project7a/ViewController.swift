import UIKit

final class ViewController: UIViewController {
    let context = CIContext()
    let model = SqueezeNet()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image = UIImage(named: "test.jpg") else { return }
        let modelSize = CGSize(width: 227, height: 227)
        
        guard let resizedPixelBuffer = CIImage(image: image)?.pixelBuffer(at: modelSize, context: context) else { return }
        let prediction = try? self.model.prediction(image: resizedPixelBuffer)
        print(prediction?.classLabel ?? "Unknown")
    }
}

extension CIImage {
    func pixelBuffer(at size: CGSize, context: CIContext) -> CVPixelBuffer? {
        let attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, attributes, &pixelBuffer)
        guard status == kCVReturnSuccess else { return nil }
        
        let scale = size.width / self.extent.size.width
        let resizedImage = self.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let width = resizedImage.extent.width
        let height = resizedImage.extent.height
        let yOffset = (CGFloat(height) - size.height) / 2.0
        let rect = CGRect(x: (CGFloat(width) - size.width) / 2.0, y: yOffset, width: size.width, height: size.height)
        
        let croppedImage = resizedImage.cropped(to: rect)
        let translatedImage = croppedImage.transformed(by: CGAffineTransform(translationX: 0, y: -yOffset))
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        context.render(translatedImage, to: pixelBuffer!)
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
