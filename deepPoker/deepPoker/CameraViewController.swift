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
    @IBOutlet weak var explanationLabel: UILabel!
    
    var gameStep = ""
    var numCards = 0
    var typeCards = ""
    
    var cards = [String]()
    
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
        
        // Defines title and number of cards
        defineStep(gameStep: gameStep)

        // Explanation label
        if numCards != 1 { explanationLabel.text = typeCards + " cards, " + String(numCards) + " separate detections" }
        else { explanationLabel.text = typeCards + " card, " + String(numCards) + " detection"}
        
        // Gives alert
        self.alert(num: cards.count)
        
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
    
    
    // Actually performs the classification and updates the camera view
    func handleClassifications(request: VNRequest, error: Error?) {
        
        let mlmodel = classifier
        let userDefined: [String: String] = mlmodel.model.modelDescription.metadata[MLModelMetadataKey.creatorDefinedKey]! as! [String : String]
        let nmsThreshold = Float(userDefined["non_maximum_suppression_threshold"]!) ?? 0.5
        
        guard let results = request.results else { return }
        var strings: [String] = []
        var boxes: [CGRect] = []
        var confidences: [Float] = []
        var cardDetected = ""
        
        for case let foundObject as VNRecognizedObjectObservation in results {
            let bestLabel = foundObject.labels.first! // Label with highest confidence
            let objectBounds = foundObject.boundingBox
            
            // Use the computed values.
            print(bestLabel.identifier, bestLabel.confidence, objectBounds)
            
            let pct = bestLabel.confidence
            strings.append(String(format: "%.2f", pct) + "%, \(bestLabel.identifier)")
            boxes.append(objectBounds)
            cardDetected = bestLabel.identifier
            confidences.append(Float(bestLabel.confidence))
            
        }
        
        DispatchQueue.main.async {
            self.cameraLayer.sublayers?.removeSubrange(1...)
            for prediction in boxes {
                self.highlightLogo(boundingRect: prediction)
            }
            self.classificationText.text = strings.joined(separator: ", ")
            
            for i in confidences{
                if i > 0.75{
                    self.captureSession.stopRunning()
                    self.detectedAlert(card: cardDetected )
                }
            }
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
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: 7)!, options: requestOptions)
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    //  Starts the detection
    func runDetector () {
        self.cameraView?.layer.addSublayer(self.cameraLayer)
        self.cameraLayer.frame = self.cameraView.bounds
        
        //        cameraLayer.videoGravity = .resizeAspectFill
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        self.captureSession.addOutput(videoOutput)
        self.captureSession.startRunning()
        self.setupVision()
    }
    
    @IBAction func dismiss(_ sender: Any) {
        captureSession.stopRunning()
//        For later will need
        self.navigationController?.popViewController(animated: true)
    }
    
    func defineStep(gameStep: String){
        
        switch gameStep {
        case "handCards":
            numCards = 2
            typeCards = "Hand"
        case "flopCards":
            numCards = 3
            typeCards = "Flop"
        case "turnCard":
            numCards = 1
            typeCards = "Turn"
        case "riverCard":
            numCards = 1
            typeCards = "River"
            
        default:
            print("Error2")
        }

    }
    

    
    func alert (num: Int) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Card " + String(num) , message: "Please detect only one card", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("OK Pressed")
            
            self.runDetector()

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            print("Cancel Pressed")
            self.navigationController?.popViewController(animated: true)
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func detectedAlert (card: String) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Detected" , message: "Detected a " + card, preferredStyle: .alert)
        
        let correctTitle = cards.count == (numCards - 1) ? "Done" : "OK"
        
        // Create the actions
        let okAction = UIAlertAction(title: correctTitle, style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("OK Pressed")
            self.cards.append(card)
            
            if self.cards.count == self.numCards {
                CardsDataSingleton.shared.data[self.typeCards] = self.cards
                self.navigationController?.popViewController(animated: true)
            }
            else{
                self.captureSession.startRunning()
            }
            
        }
        
        let retryAction = UIAlertAction(title: "Retry", style: UIAlertAction.Style.default) {
            UIAlertAction in
            print("Retry Pressed")
            self.captureSession.startRunning()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            print("Cancel Pressed")
            self.navigationController?.popViewController(animated: true)
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(retryAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
    }
    
}
