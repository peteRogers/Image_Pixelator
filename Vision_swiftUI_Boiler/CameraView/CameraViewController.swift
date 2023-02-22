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
    
    private let videoDataOutputQueue = DispatchQueue(
        label: "CameraFeedOutput",
        qos: .userInteractive
    )
    private var cameraFeedSession: AVCaptureSession?

    private var preImage: VNImageRequestHandler?
    
    var score: ((Float) -> Void)?
    
   
    
   
    
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
        let handler = VNImageRequestHandler(
            cmSampleBuffer: sampleBuffer,
            orientation: .up,
            options: [:]
        )
        if preImage == nil{
            //print(preImage.debugDescription)
            preImage = handler
        }
        
        var observation : VNFeaturePrintObservation?
        var sourceObservation : VNFeaturePrintObservation?
        sourceObservation = featureprintObservationForImage(requestHandler: handler)
        if let l = preImage{
            observation = featureprintObservationForImage(requestHandler: l)
        }
        do{
            var distance = Float(0)
            if let sourceObservation = sourceObservation{
                try observation?.computeDistance(&distance, to: sourceObservation)
               
                if( distance > 5){
                    print("yes: \(Date.now)")
                    preImage = handler
                    score?(distance)
                }else{
                    print("no: \(Date.now)")
                    score?(Float.random(in: -1 ... 0))
                }
            }
        }catch{
            print("error occured")
        }
        
        
        
       
    }
    
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
