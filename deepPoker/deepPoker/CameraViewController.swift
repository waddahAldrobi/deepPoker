//
//  CameraViewController.swift
//  deepPoker
//
//  Created by Waddah Al Drobi on 2019-04-14.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreML


class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    @IBOutlet weak var classificationText: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    private var requests = [VNRequest]()
    
    // Create a layer to display camera frames in the UIView
    private lazy var cameraLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    
    // Create an AVCaptureSession, opens the camera
    private lazy var captureSession: AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera)
            else { return session }
        session.addInput(input)
        return session
    }()
    
    private lazy var classifier: CardDetector = CardDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        cameraView?.layer.addSublayer(cameraLayer)
        cameraLayer.frame = cameraView.bounds
        
        //        cameraLayer.videoGravity = .resizeAspectFill
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()
        setupVision()
    }
    
    // Takes care of sizing the camera view over the camera layer
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }
    
    // Calls the model and starts the request
    func setupVision() {
        guard let visionModel = try? VNCoreMLModel(for: classifier.model) else {
            fatalError("Can’t load VisionML model")
        }
        let classificationRequest = VNCoreMLRequest(model: visionModel, completionHandler: handleClassifications)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFill
        requests = [classificationRequest]
    }
    
    
    // Actuualy performs the classification and updates the camera view
    func handleClassifications(request: VNRequest, error: Error?) {
        
        let mlmodel = classifier
        let userDefined: [String: String] = mlmodel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey]! as! [String : String]
        let nmsThreshold = Float(userDefined["non_maximum_suppression_threshold"]!) ?? 0.5
        
        guard let results = request.results else { return }
        var strings: [String] = []
        var boxes: [CGRect] = []
        
        for case let foundObject as VNRecognizedObjectObservation in results {
            let bestLabel = foundObject.labels.first! // Label with highest confidence
            let objectBounds = foundObject.boundingBox
            
            // Use the computed values.
            print(bestLabel.identifier, bestLabel.confidence, objectBounds)
            
            let pct = bestLabel.confidence
            strings.append(String(format: "%.2f", pct) + "%, \(bestLabel.identifier)")
            boxes.append(objectBounds)
            
        }
        
        DispatchQueue.main.async {
            self.cameraLayer.sublayers?.removeSubrange(1...)
            for prediction in boxes {
                self.highlightLogo(boundingRect: prediction)
            }
            self.classificationText.text = strings.joined(separator: ", ")
        }
    }
    
    // Draws the actual bounding box
    func highlightLogo(boundingRect: CGRect) {
        let source = self.cameraView.frame
        
        let rectWidth = source.size.width * boundingRect.size.width
        let rectHeight = source.size.height * boundingRect.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: boundingRect.origin.x * source.size.width, y:boundingRect.origin.y * source.size.height, width: rectWidth, height: rectHeight)
        
        
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.red.cgColor
        
        self.cameraLayer.addSublayer(outline)
    }
    
    // The actual function that runs due to the delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var requestOptions:[VNImageOption : Any] = [:]
        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics:cameraIntrinsicData]
        }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 6)!, options: requestOptions)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    @IBAction func dismiss(_ sender: Any) {
        captureSession.stopRunning()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
}
