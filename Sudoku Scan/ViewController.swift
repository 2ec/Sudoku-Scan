//
//  ViewController.swift
//  Sudoku Scan
//
//  Created by Emil Christopher Gjøstøl Strømsvåg on 27/07/2020.
//  Copyright © 2020 Emil Christopher Gjøstøl Strømsvåg. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    
    //@IBOutlet weak var Teller: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addImage: UIButton!
    @IBOutlet weak var grid: UICollectionView!
    @IBOutlet weak var textLabel: UILabel!
    // Test comment
    
    
    //var teller:Int = 0
    var rotationCode = 4 // No rotation

    
    var textRecognitionRequest = VNRecognizeTextRequest()
    var textDetectionRequest = VNDetectRectanglesRequest()
    var recognizedText = ""
    var textArray = [String]()
    var imageArr = [[CGImage]]() // will contain small pieces of image
    private var requestsDetected = [VNRequest]()
    let model = myMNIST()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(OpenCV.openCVVersionString())")
        // Do any additional setup after loading the view.
        //setupVision()
        //setupModel()
        setupTextDetection()
        //print("viewDidLoad")
        
        
    }
    
    private func setupVision(){
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNRecognizedTextObservation] {
                    self.recognizedText = ""
                    for observation in requestResults {
                        guard let candidiate = observation.topCandidates(1).first else { return }
                          self.recognizedText = candidiate.string
                        //self.recognizedText += "\n"
                        
                        if self.recognizedText.contains("11") {
                            self.textArray.append("0")
                            print("fant 11")
                       }else{
                           //self.catDetailsTextView.text = self.recognizedText
                           print(self.recognizedText)
                           self.textArray.append(candidiate.string)
                       }
                    }
                    
                }
            }else{
                //print("0")
                self.textArray.append("0")
            }
        })
        
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.usesLanguageCorrection = false
        
    }
    
    private func printBoard(){
        var counter = 0
        print("Lengde:",textArray.count)
        
        for i in 0..<textArray.count {
            if counter < 8 {
                print(textArray[i]," ", terminator:"")
                counter += 1
            }else{
                print(textArray[i])
                counter = 0
            }
            
        }
    }
    
    private func setupTextDetection(){
        print("DEBUG - setupTextDetection")
        self.textDetectionRequest = VNDetectRectanglesRequest(completionHandler: { (request, error) in
            if let results = request.results, !results.isEmpty {
                if let requestResults = request.results as? [VNObservation] {
                    for observation in requestResults{
                        self.textArray.append(String(format: "%.2f", observation.confidence))
                        return
                    }
                }else{
                    print("Hit")
                }
            }else{
                self.textArray.append("0")
            }
            
        })
        
        self.requestsDetected = [textDetectionRequest]
        //textDetectionRequest.usesCPUOnly = false
        textDetectionRequest.minimumSize = 0.2
        //textDetectionRequest.maximumAspectRatio = 0.7
        textDetectionRequest.minimumAspectRatio = 0.1
        textDetectionRequest.minimumConfidence = 0.0
        textDetectionRequest.maximumObservations = 1
        textDetectionRequest.quadratureTolerance = 45
    }
    
    
    
    
    private func setupModel(image: CGImage){
       guard let model = try? VNCoreMLModel(for: myMNIST().model) else { return }
        // run an inference with CoreML
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            // grab the inference results
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            // grab the highest confidence result
            guard let Observation = results.first else { return }
            
            //print(Observation.identifier, "-", Observation.confidence)
            // create the label text components
            let predclass = "\(Observation.identifier)"
            // set the label text
            
            self.textArray.append("\(predclass)")
            //DispatchQueue.main.async(execute: {//print(predclass)})
        }
        try? VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
        
        //print("DEBUG - Fant bildet.")
        
        let orientation = selectedImage.imageOrientation.rawValue
        
        if orientation == 0 {
            //print("(Opp) = Landskap med volumknapper ned - ", selectedImage.imageOrientation.rawValue)
            rotationCode = 4
        }else if orientation == 1 {
            //print("(Ned) = Landskap med volumknapper opp - ", selectedImage.imageOrientation.rawValue)
            rotationCode = 1
        }else if orientation == 2 {
            //print("(Venstre) - Opp ned", selectedImage.imageOrientation.rawValue)
            rotationCode = 2
        }else if orientation == 3 {
            //print("(Høyre) = Portrett - ", selectedImage.imageOrientation.rawValue)
            rotationCode = 0
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = OpenCV.makeGray(selectedImage, rotation: Int32(rotationCode))
    }
    

    //MARK: Actions
    @IBAction func knapp(_ sender: Any) {
        //print("rotationCode", rotationCode)
        //photoImageView.image = OpenCV.makeGray(photoImageView.image!, rotation: Int32(rotationCode))
        splitImage(image: photoImageView.image!, row: 9, column: 9)
        //photoImageView.image = UIImage(cgImage: imageArr[5][5])
        //detectText(image: photoImageView.image!)
        itterateImageForNumbers(row: 9, column: 9)
        //print(self.textArray)
        //print("Count:", self.textArray.count)
        
        printBoard()
        print("ferdig")
    }
    
    
    private func itterateImageForNumbers(row: Int, column: Int){
        textArray.removeAll()
        for y in 0..<row {
            for x in 0..<column {
                setupModel(image: imageArr[y][x])
                //setupVision()
                //setupTextDetection(image: imageArr[y][x])
                //detectText(image: imageArr[y][x])
                //detectTextNew(image: imageArr[y][x])
                //createVisionRequest(image: imageArr[y][x])
                /*guard let predicted = try? model.prediction(image: imageArr[y][x] as! CVPixelBuffer) else{
                    fatalError("This did not work...")
                }
                print(predicted.classLabel)*/
                //print(y, x)
            }
        }
    }
 
    
    private func detectText(image: CGImage){
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print(error)
        }
    }
    
    private func detectTextNew(image: CGImage){
         let handler = VNImageRequestHandler(cgImage: image, options: [:])
         do {
             try handler.perform([textDetectionRequest])
         } catch {
             print(error)
         }
     }
    
    
    
    @IBAction func addImagePushed(_ sender: Any) {
        //print("DEBUG - addImagePushed.")
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        
        imagePickerController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    // Splittng an image
    func splitImage(image: UIImage, row : Int , column : Int){
        imageArr.removeAll()

        let oImg = image
        let height = (image.size.height) / CGFloat (row) //height of each image tile
        let width = (image.size.width) / CGFloat (column)  //width of each image tile
        let scale = (image.scale) //scale conversion factor is needed as UIImage make use of "points" whereas CGImage use pixels.
        
        for y in 0..<row{
            var yArr = [CGImage]()
            for x in 0..<column{
                //UIGraphicsBeginImageContextWithOptions(CGSize(width:width, height:height), false, 0)
                let i = oImg.cgImage?.cropping(to: CGRect.init(x: CGFloat(x) * width * scale, y: CGFloat(y) * height * scale, width: width * scale, height: height * scale))
                
                //let newImg = UIImage.init(cgImage: i!)
                //yArr.append(newImg)
                yArr.append(i!)
                //UIGraphicsEndImageContext();
            }
            imageArr.append(yArr)
        }
    }
    
    //Mark: - Rectangle detection
    func createVisionRequest(image: CGImage) {

        let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        let request = VNDetectRectanglesRequest { request, error in
            self.completedVisionRequest(request, error: error)
        }
        

        request.maximumObservations = 1
        request.minimumAspectRatio = 0.0
        request.maximumAspectRatio = 1
        request.minimumSize = 0.2
        request.quadratureTolerance = 45
        request.minimumConfidence = 0.0
        
        request.usesCPUOnly = false
        do {
        try requestHandler.perform([request])
        }catch {
            print("Error: Rectangle detection failed - vision request failed.")
        }
    }
    
    
    func completedVisionRequest(_ request: VNRequest?, error: Error?) {
        //print("completedVisionRequest")
        guard let requestResults = request?.results as? [VNObservation] else {
            guard let error = error else { return }
            print("Error: Rectangle detection failed with error: \(error.localizedDescription)")
            return
        }
        if let results = request?.results, !results.isEmpty {
            for observation in requestResults{
                self.textArray.append(String(format: "%.1f", observation.confidence))
            }
        }else{
            self.textArray.append("0.0")
        }
        //print("Found \(rectangles.count) rectangles")
    }
}
