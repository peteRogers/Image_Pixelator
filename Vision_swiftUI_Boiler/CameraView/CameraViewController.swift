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

    
    
    var score: (([VNBarcodeObservation]) -> Void)?
    
    private var counter = 0
    
   
    
    override func loadView() {
        
        view = CameraPreview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraFeedSession == nil {
                try setupAVSession()
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
        if(counter > 2){
            counter = 0
            guard let frame = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                debugPrint("unable to get image from sample buffer")
                return
            }
            let barcodeRequest = VNDetectBarcodesRequest()
            barcodeRequest.symbologies = [.qr]
            try? self.sequenceHandler.perform([barcodeRequest], on: frame)
            if let results = barcodeRequest.results {
                score?(results)
            }
            
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
