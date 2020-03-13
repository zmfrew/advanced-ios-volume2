//
//  ViewController.swift
//  Project8-Depth
//
//  Created by Paul Hudson on 30/06/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import UIKit
import ImageIO

class ViewController: UIViewController {
    let aperture = UISlider()
    var context: CIContext!
    var depthImage: CIImage!
    var disparityImage: CIImage!
    var focusRect = CGRect(x: 0.5, y: 0.5, width: 0.2, height: 0.2)
    let imageView = UIImageView()
    var mainImage: CIImage!

    var displayMode = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Mode", style: .plain, target: self, action: #selector(changeDisplayMode))
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        aperture.minimumValue = 1
        aperture.maximumValue = 22
        aperture.value = 8
        aperture.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(aperture)
        
        aperture.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        aperture.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        aperture.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30).isActive = true
        aperture.addTarget(self, action: #selector(drawImage), for: .valueChanged)

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(refocus))
        recognizer.delaysTouchesBegan = true
        imageView.addGestureRecognizer(recognizer)
        imageView.isUserInteractionEnabled = true

        context = CIContext(options: [.workingFormat: CIFormat.RGBAh])
        loadImage()
    }

    func loadImage() {
        guard let url = Bundle.main.url(forResource: "toy", withExtension: "heic") else { return }
        
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil) {
            let auxDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0, kCGImageAuxiliaryDataTypeDisparity)
            
            if auxDataInfo == nil {
                print("No depth for that image!")
            } else {
                print("Got depth!")
                mainImage = CIImage(contentsOf: url)
                disparityImage = CIImage(contentsOf: url, options: [.auxiliaryDisparity: true])
                depthImage = CIImage(contentsOf: url, options: [.auxiliaryDepth: true])
                drawImage()
            }
        }
    }

    @objc func drawImage() {
        title = "Aperture: \(aperture.value)"
        guard let mainImage = mainImage,
            let disparityImage = disparityImage,
            let filter = CIFilter(name: "CIDepthBlurEffect", parameters: [kCIInputImageKey: mainImage, kCIInputDisparityImageKey: disparityImage]) else { return }
        
        filter.setValue(aperture.value, forKey: "inputAperture")
        filter.setValue(CIVector(cgRect: focusRect), forKey: "inputFocusRect")
        
        guard let output = filter.outputImage else { return }
        
        let imageToDisplay: CIImage
        switch displayMode {
        case 1:
            imageToDisplay = depthImage
        case 2:
            imageToDisplay = disparityImage
        default:
            imageToDisplay = output
        }
        
        if let result = context.createCGImage(imageToDisplay, from: imageToDisplay.extent) {
            imageView.image = UIImage(cgImage: result)
        }
    }

    @objc func refocus(recognizer: UITapGestureRecognizer) {
        guard let bounds = recognizer.view?.bounds else { return }
        let touch = recognizer.location(in: recognizer.view)
        
        let x = touch.x / bounds.size.width
        let y = 1.0 - (touch.y / bounds.size.height)
        
        focusRect = CGRect(x: x - 0.1, y: y - 0.1, width: 0.2, height: 0.2)
        drawImage()
    }

    @objc func changeDisplayMode() {
        displayMode += 1
        if displayMode == 3 { displayMode = 0 }
        drawImage()
    }
}
