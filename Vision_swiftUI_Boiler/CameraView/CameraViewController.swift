//
//  CameraViewController.swift
//  vision_swiftUI
//
//  Created by Peter Rogers on 07/12/2022.
//


import UIKit
import AVFoundation
import Vision

final class CameraViewController: UIViewController {
    
    private var cameraView: CameraPreview { view as! CameraPreview }
    private let sequenceHandler = VNSequenceRequestHandler()
    private let videoDataOutputQueue = DispatchQueue(
        label: "CameraFeedOutput",
        qos: .userInteractive
    )
    private var cameraFeedSession: AVCaptureSession?

    
    
    var score: ((String) -> Void)?
    
    private var counter = 0
    
   
    
    override func loadView() {
        
        view = CameraPreview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                try setupAVSession()
               // cameraView.previewLayer.connection?.videoOrientation = .portrait
                cameraView.previewLayer.session = cameraFeedSession
//                if (cameraView.previewLayer.connection!.isVideoMirroringSupported) {
//                    print("Is supported mirroring")
//                    cameraView.previewLayer.connection!.automaticallyAdjustsVideoMirroring = false
//                    cameraView.previewLayer.connection!.isVideoMirrored = false
//                }
                //cameraView.previewLayer.videoGravity = .resizeAspect
                
            }
            DispatchQueue.global(qos: .userInitiated).async{
                self.cameraFeedSession?.startRunning()
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cameraFeedSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    func setupAVSession() throws {
        
        // Select a front facing camera, make an input.
        
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front)
        else {
            throw AppError.captureSessionSetup(
                reason: "Could not find a front facing camera."
            )
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(
            device: videoDevice
        ) else {
            throw AppError.captureSessionSetup(
                reason: "Could not create video device input."
            )
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        
        session.sessionPreset = AVCaptureSession.Preset.high
        
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(
                reason: "Could not add video device input to the session"
            )
        }
        session.addInput(deviceInput)
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(
                reason: "Could not add video data output to the session"
            )
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }
    
   
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

  
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,from connection: AVCaptureConnection) {
        
                counter += 1
        if(counter > 10){
            counter = 0
            guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                debugPrint("unable to get image from sample buffer")
                return
            }
            let barcodeRequest = VNDetectBarcodesRequest()
            barcodeRequest.symbologies = [.qr]
            try? self.sequenceHandler.perform([barcodeRequest], on: frame)
            if let results = barcodeRequest.results {
                //print("nothing here")
                for result in results{
                    print(result.payloadStringValue)
                    print(result.boundingBox.midX)
                }
            }
            
        }
        
    }
    
    
   
    
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,from connection: AVCaptureConnection) {
//        counter += 1
//        if(counter > 10){
//            counter = 0
//            let handler = VNImageRequestHandler(
//                cmSampleBuffer: sampleBuffer,
//                orientation: .up,
//                options: [:]
//            )
//
//
//            //        if preImage == nil{
//            //            //print(preImage.debugDescription)
//            //            preImage = handler
//            //        }
//            //
//            //        var observation : VNFeaturePrintObservation?
//            //        var sourceObservation : VNFeaturePrintObservation?
//            //        sourceObservation = featureprintObservationForImage(requestHandler: handler)
//            //        if let l = preImage{
//            //            observation = featureprintObservationForImage(requestHandler: l)
//            //        }
//            //        do{
//            //            var distance = Float(0)
//            //            if let sourceObservation = sourceObservation{
//            //                try observation?.computeDistance(&distance, to: sourceObservation)
//            //
//            //                if( distance > 5){
//            //                    print("yes: \(Date.now)")
//            //                    preImage = handler
//            //                    score?(distance)
//            //                }else{
//            //                    print("no: \(Date.now)")
//            //                    score?(Float.random(in: -5 ... 1))
//            //                }
//            //            }
//            //        }catch{
//            //            print("error occured")
//            //        }
//            //
//
//
//            // self.score?(["aa","bb","CC"])
//
//            /////////////////////////
//
//            let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
//                guard let observations = request.results as? [VNRecognizedTextObservation] else {
//                    return
//                }
//
//                var recognizedStrings = observations.compactMap { observation in
//                    observation.topCandidates(1).first?.string
//                    // print(observation.debugDescription)
//                }
//
//                let boundingRects: [CGRect] = observations.compactMap { observation in
//
//                    // Find the top observation.
//                    guard let candidate = observation.topCandidates(1).first else { return .zero }
//
//                    // Find the bounding-box observation for the string range.
//                    let stringRange = candidate.string.startIndex..<candidate.string.endIndex
//                    let boxObservation = try? candidate.boundingBox(for: stringRange)
//
//                    // Get the normalized CGRect value.
//                    return boxObservation?.boundingBox ?? .zero
//
////                    // Convert the rectangle from normalized coordinates to image coordinates.
////                    return VNImageRectForNormalizedRect(boundingBox,
////                                                        Int(image.size.width),
////                                                        Int(image.size.height))
//                }
//
//                DispatchQueue.main.async {
//                     print(recognizedStrings)
//                     print(boundingRects)
//
//                    var singleString = ""
//                    for i in recognizedStrings{
//                        //print(i)
//                        let a = String(i.filter { !" ".contains($0) })
//                        singleString.append(a)
//                        // print(a)
//                       // output.append(a)
//
//                    }
//
//                    self.score?(singleString)
//
//                }
//            }
//
//            recognizeTextRequest.recognitionLevel = .accurate
//
//            DispatchQueue.global(qos: .userInitiated).async {
//                do {
//                    try handler.perform([recognizeTextRequest])
//                } catch {
//                    print(error)
//                }
//            }
//
//        }
//
//
//    }
    
    
   
    
    func featureprintObservationForImage(requestHandler: VNImageRequestHandler) -> VNFeaturePrintObservation? {
       
        let request = VNGenerateImageFeaturePrintRequest()
        do {
            try requestHandler.perform([request])
            return request.results?.first as? VNFeaturePrintObservation
        } catch {
            print("Vision error: \(error)")
            return nil
        }
    }
}
