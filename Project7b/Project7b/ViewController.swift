import AVKit
import UIKit

enum SetupError: Error {
    case noVideoDevice, videoInputFailed, videoOutputFailed
}

class ViewController: UIViewController {
    var assetWriter: AVAssetWriter!
    var capturePreview = CapturePreviewView()
    let context = CIContext()
    let model = SqueezeNet()
    var movieURL: URL!
    var predictions = [(time: CMTime, prediction: String)]()
    let readyToAnalyze = true
    var recordingActive = false
    let session = AVCaptureSession()
    var startTime: CMTime!
    let videoOutput = AVCaptureVideoDataOutput()
    var writerInput: AVAssetWriterInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        capturePreview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(capturePreview)
        capturePreview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        capturePreview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        capturePreview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        capturePreview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        (capturePreview.layer as! AVCaptureVideoPreviewLayer).session = session
        
        do {
            try configureSession()
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Record", style: .plain, target: self, action: #selector(startRecording))
        } catch {
            print("Session configuration failed!")
        }
    }
    
    @objc func startRecording() {
        recordingActive = true
        session.startRunning()
    }
    
    func configureSession() throws {
        session.beginConfiguration()
        try configureVideoDeviceInput()
        session.commitConfiguration()
    }
    
    func configureVideoDeviceInput() throws {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            throw SetupError.noVideoDevice
        }
        
        let videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if session.canAddInput(videoDeviceInput) {
            session.addInput(videoDeviceInput)
        } else {
            throw SetupError.videoInputFailed
        }
    }
}
