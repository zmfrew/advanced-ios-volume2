import AVFoundation
import UIKit

class CapturePreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
}
