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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Stop", style: .plain, target: self, action: #selector(stopRecording))
    }
    
    @objc func stopRecording() {
        recordingActive = false

        assetWriter?.finishWriting {
            if (self.assetWriter?.status == .failed) {
                print("Failed to save.")
            } else {
                print("Succeeded saving.")
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connetion: AVCaptureConnection) {
        guard recordingActive else { return }
        guard CMSampleBufferDataIsReady(sampleBuffer) == true else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)

        if assetWriter.status == .unknown {
            // store this away so we can calculate time offsets later
            startTime = currentTime

            // start writing data to disk
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: currentTime)

            // we're done for now, so exit
            return
        }
        
        if assetWriter.status == .failed { return }
        if writerInput.isReadyForMoreMediaData {
            writerInput.append(sampleBuffer)
        }
    }
    
    func configureMovieWriting() throws {
        movieURL = getDocumentsDirectory().appendingPathComponent("movie.mov")
        let fm = FileManager.default
        
        if fm.fileExists(atPath: movieURL.path) {
            try fm.removeItem(at: movieURL)
        }
        
        assetWriter = try AVAssetWriter(url: movieURL, fileType: .mp4)
        let settings = videoOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mp4)
        writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        writerInput.expectsMediaDataInRealTime = true
        
        if assetWriter.canAdd(writerInput) {
            assetWriter.add(writerInput)
        }
    }
    
    func configureSession() throws {
        session.beginConfiguration()
        try configureVideoDeviceInput()
        try configureVideoDeviceOutput()
        try configureMovieWriting()
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
    
    func configureVideoDeviceOutput() throws {
        if session.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            session.addOutput(videoOutput)
            for connection in videoOutput.connections {
                for port in connection.inputPorts {
                    if port.mediaType == .video {
                        connection.videoOrientation = .portrait
                    }
                }
            }
        } else {
            throw SetupError.videoOutputFailed
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
}
