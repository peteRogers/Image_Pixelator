//
//  ImageView.swift
//  Image_Pixelator
//
//  Created by Peter Rogers on 22/02/2023.
//

import Foundation
import UIKit
import SwiftUI


class ImageView: UIView {
    // 1
    var imageToPixelate:UIImage?
    var sourceImg: UIImage?
    var outputImg: UIImage?
    var imgView: UIImageView?
    var cScore:Float = 0.0
    var score: Float?
    
   
    
    init(score: Float) {
        super.init(frame: .zero)
        self.score = score
       
        sourceImg = UIImage(named:"tester.png")
        // 2
       // outputImg = sourceImg
        imgView = UIImageView(image: outputImg)
        
        backgroundColor = .black
       
        addSubview(imgView!)
        NSLayoutConstraint.activate([
            imgView!.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imgView!.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            imgView!.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            imgView!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
    }
        
    
    
    func filterImg(){
        let context = CIContext(options: nil)
       // print(score)
       
        cScore = cScore + (score ?? 0)
        if(cScore < 1){
            cScore = 1
        }
        
        if let currentFilter = CIFilter(name: "CIPixellate") {
           
            let beginImage = CIImage(image: sourceImg!)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            currentFilter.setValue(cScore, forKey: kCIInputScaleKey)
            currentFilter.setValue(CIVector(x: (sourceImg?.size.width ?? 0)/2,y: (sourceImg?.size.height ?? 0)/2), forKey: kCIInputCenterKey)
            
            if let output = currentFilter.outputImage {
                if let cgimg = context.createCGImage(output, from: output.extent) {
                    outputImg = UIImage(cgImage: cgimg)
                    imgView?.frame = self.frame
                    imgView?.image = outputImg
                   
                    imgView?.contentMode = .center
                   
                    // do something interesting with the processed image
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct RepresentedImageView: UIViewRepresentable {
    typealias UIViewType = ImageView
    @Binding var score:Float
  
    func makeUIView(context: Context) -> ImageView {
        let view = ImageView(score: score)

        // Do some configurations here if needed.
        return view
    }
    
    init(score: Binding<Float>){
        self._score = score
    }
    
    func updateUIView(_ uiView: ImageView, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
        
        uiView.score = score
       // uiView.label.text = ":\(score)"
        uiView.filterImg()
        uiView.setNeedsDisplay()
        
    }
}
