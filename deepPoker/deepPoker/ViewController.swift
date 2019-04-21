//
//  ViewController.swift
//  deepPoker
//
//  Created by Waddah Al Drobi on 2019-04-14.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var handLabel: UILabel!
    @IBOutlet weak var flopLabel: UILabel!
    @IBOutlet weak var turnLabel: UILabel!
    @IBOutlet weak var riverLabel: UILabel!
    
    @IBOutlet weak var probabilitiesLabel: UILabel!
    
    var handCards = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changeStepLabels()
        
        if !(CardsDataSingleton.shared.handsClassifications.isEmpty){
            print(CardsDataSingleton.shared.handsClassifications)
            let dict = CardsDataSingleton.shared.handsClassifications
            var label = ""
            for i in dict {
                label = label +  i.0 + ","
            }
            probabilitiesLabel.text = label
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CameraViewController
        destinationVC.gameStep = segue.identifier ?? "Error1"
    }
    
    // Sets the cards the players has to specfic step
    func changeStepLabels() {
        let dict = CardsDataSingleton.shared.data
        var label = ""
        if let hand = dict["Hand"] {
            label = hand.joined(separator: ", ")
            handLabel.text = label
        }
        
        if let flop = dict["Flop"] {
            // now val is not nil and the Optional has been unwrapped, so use it
            label = flop.joined(separator: ", ")
            flopLabel.text = label
        }
        
        if let turn = dict["Turn"] {
            // now val is not nil and the Optional has been unwrapped, so use it
            label = turn.joined(separator: ", ")
            turnLabel.text = label
        }
        
        if let river = dict["River"] {
            // now val is not nil and the Optional has been unwrapped, so use it
            label = river.joined(separator: ", ")
            riverLabel.text = label
        }
    }
}


// Test on a static imageview: no need for it
// in this app

//@IBOutlet weak var imageView: UIImageView!
//@IBOutlet weak var classificationLabel: UILabel!
//
//var nmsThreshold: Float = 0.5
//var inputImage: CIImage?
//
//override func viewDidLoad() {
//    super.viewDidLoad()
//
//    // Caslls test image
//    guard let image = UIImage(contentsOfFile: Bundle.main.path(forResource: "cards-[D0]-002", ofType: "jpg")!) else {
//        return
//    }
//    guard let ciImage = CIImage(image: image)
//        else { fatalError("can't create CIImage from UIImage") }
//
//    print("orr:", UInt32(image.imageOrientation.rawValue))
//
//    let orientation = CGImagePropertyOrientation(rawValue: 2)
//    inputImage = ciImage.oriented(forExifOrientation: Int32(orientation!.rawValue))
//
//    // Show the image in the UI.
//    imageView.image = image
//
//    // Run the rectangle detector
//    let handler = VNImageRequestHandler(ciImage: ciImage, orientation: (orientation)!)
//    DispatchQueue.global(qos: .userInteractive).async {
//        do {
//            try handler.perform([self.detectionRequest])
//        } catch {
//            print(error)
//        }
//    }
//}
//
//// Load the model and create a Vision request for it.
//lazy var detectionRequest: VNCoreMLRequest = {
//    do {
//        let model = try VNCoreMLModel(for: CardDetector().model)
//
//        return VNCoreMLRequest(model: model, completionHandler: self.handleDetection)
//    } catch {
//        fatalError("can't load Vision ML model: \(error)")
//    }
//}()
//
//struct Prediction {
//    let labelIndex: Int
//    let confidence: Float
//    let boundingBox: CGRect
//}
//
//// Gets the results of the model
//// And calls to draw boudning boxes
//func handleDetection(request: VNRequest, error: Error?) {
//
//    guard let results = request.results else { return }
//
//    var strings: [String] = []
//
//    for case let foundObject as VNRecognizedObjectObservation in results {
//        let bestLabel = foundObject.labels.first! // Label with highest confidence
//        let objectBounds = foundObject.boundingBox
//
//        // Use the computed values.
//        print(bestLabel.identifier, bestLabel.confidence, objectBounds)
//
//        let pct = bestLabel.confidence
//        strings.append("\(pct)%")
//        drawRectangle(detectedRectangle: objectBounds)
//    }
//
//    DispatchQueue.main.async {
//        self.classificationLabel.text = strings.joined(separator: ", ")
//    }
//}
//
//// Drwas boudning boxes
//public func drawRectangle(detectedRectangle: CGRect) {
//    guard let inputImage = inputImage else {
//        return
//    }
//    // Verify detected rectangle is valid.
//    let boundingBox = detectedRectangle.scaled(to: inputImage.extent.size)
//    guard inputImage.extent.contains(boundingBox) else {
//        print("invalid detected rectangle");
//        return
//    }
//
//    // Show the pre-processed image
//    DispatchQueue.main.async {
//        self.imageView.image = self.drawOnImage(source: self.imageView.image!, boundingRect: detectedRectangle)
//    }
//}
//
//// Draws the corresponding box on the image
//fileprivate func drawOnImage(source: UIImage,
//                             boundingRect: CGRect) -> UIImage {
//    UIGraphicsBeginImageContextWithOptions(source.size, false, 1)
//    let context = UIGraphicsGetCurrentContext()!
//    context.translateBy(x: source.size.width, y: 0)
//    context.scaleBy(x: -1.0, y: 1.0)
//    context.setLineJoin(.round)
//    context.setLineCap(.round)
//    context.setShouldAntialias(true)
//    context.setAllowsAntialiasing(true)
//
//    let rectWidth = source.size.width * boundingRect.size.width
//    let rectHeight = source.size.height * boundingRect.size.height
//
//    //draw image
//    let rect = CGRect(x: 0, y:0, width: source.size.width, height: source.size.height)
//    context.draw(source.cgImage!, in: rect)
//
//
//    //draw bound rect
//    var fillColor = UIColor.green
//    fillColor.setFill()
//    context.addRect(CGRect(x: boundingRect.origin.x * source.size.width, y:boundingRect.origin.y * source.size.height, width: rectWidth, height: rectHeight))
//
//    //draw overlay
//    fillColor = UIColor.red
//    fillColor.setStroke()
//    context.setLineWidth(12.0)
//    context.drawPath(using: CGPathDrawingMode.stroke)
//
//    let coloredImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//    UIGraphicsEndImageContext()
//    return coloredImg
//}
//

//extension CGRect {
//    func scaled(to size: CGSize) -> CGRect {
//        return CGRect(
//            x: self.origin.x * size.width,
//            y: self.origin.y * size.height,
//            width: self.size.width * size.width,
//            height: self.size.height * size.height
//        )
//    }
//}
//
//
//extension UIImage {
//    func rotate(radians: CGFloat) -> UIImage {
//        let rotatedSize = CGRect(origin: .zero, size: size)
//            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
//            .integral.size
//        UIGraphicsBeginImageContext(rotatedSize)
//        if let context = UIGraphicsGetCurrentContext() {
//            let origin = CGPoint(x: rotatedSize.width / 2.0,
//                                 y: rotatedSize.height / 2.0)
//            context.translateBy(x: origin.x, y: origin.y)
//            context.rotate(by: radians)
//            draw(in: CGRect(x: -origin.x, y: -origin.y,
//                            width: size.width, height: size.height))
//            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//
//            return rotatedImage ?? self
//        }
//
//        return self
//    }
//}

