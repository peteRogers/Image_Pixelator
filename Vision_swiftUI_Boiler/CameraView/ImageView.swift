//
//  ImageView.swift
//  Image_Pixelator
//
//  Created by Peter Rogers on 22/02/2023.
//

import Foundation
import UIKit
import SwiftUI
import Vision


class ImageView: UIView {
    // 1
//    var imageToPixelate:UIImage?
//    var sourceImg: UIImage?
//    var outputImg: UIImage?
    var blocks: [ImageBlock] = []
    let letters:[Character] = ["X", "M", "W", "Z", "A", "P", "T", "K", "E", "N", "U", "C", "D", "L", "S", "B"]
    //let letters:[Character] = ["S", "B", "P", "X"]
    
    var score: [VNBarcodeObservation]?
    
   
    
    init(score: [VNBarcodeObservation]) {
        super.init(frame: .zero)
        self.score = score
        var p = 0
        for letter in letters{
            
//                let iv = UIImageView(frame: (CGRect(x: x, y: y, width: w / 4 , height: h / 4)))
            let im = UIImage(named:"\(p).png")
            //let im = generateQRCode(from: "\(letter)")
            let iv = UIImageView(image: im)
            iv.contentMode = .scaleAspectFit
            iv.alpha = 0.5
            let imageBlock = ImageBlock(iv: iv, rawImg: im!,  letter: letter, center: CGRect())
            self.addSubview(imageBlock.iv)
            imageBlock.setImage()
            blocks.append(imageBlock)
            p += 1
        }
        self.backgroundColor = .clear
    }
        
    override func layoutSubviews() {
        
            super.layoutSubviews()

        }
    
    
    
    
    func sortQRCodePositions(){
        if let codes = score{
            for code in codes{
                if let idx = blocks.firstIndex(where: { $0.letter == code.payloadStringValue?.first}) {
                    blocks[idx].setCenter(pos:code.boundingBox)
                    blocks[idx].setBlockPosition(rect: self.frame)
                }
            }
        }
    }
   

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
//    
//    func filterImg(){
//        let context = CIContext(options: nil)
//        if let currentFilter = CIFilter(name: "CIPixellate") {
//           
//            let beginImage = CIImage(image: sourceImg!)
//            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
//            currentFilter.setValue(1, forKey: kCIInputScaleKey)
//            currentFilter.setValue(CIVector(x: (sourceImg?.size.width ?? 0)/2,y: (sourceImg?.size.height ?? 0)/2), forKey: kCIInputCenterKey)
//            
//            if let output = currentFilter.outputImage {
//                if let cgimg = context.createCGImage(output, from: output.extent) {
//                    outputImg = UIImage(cgImage: cgimg)
//                }
//            }
//        }
//    }
//    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct RepresentedImageView: UIViewRepresentable {
    typealias UIViewType = ImageView
    @Binding var score:[VNBarcodeObservation]
  
    func makeUIView(context: Context) -> ImageView {
        let view = ImageView(score: score)

        // Do some configurations here if needed.
        return view
    }
    
    init(score: Binding<[VNBarcodeObservation]>){
        self._score = score
    }
    
    func updateUIView(_ uiView: ImageView, context: Context) {
        uiView.score = score
        uiView.sortQRCodePositions()
        uiView.setNeedsDisplay()
        
    }
}

struct ImageBlock{
    
    var iv:UIImageView
    var rawImg: UIImage
    var letter:Character
    var cPos:Int = 0
    var center:CGRect
   
   
    
    mutating func setCenter(pos:CGRect){
        center = pos
       
    }
    
//    func resizeBlock( w:CGFloat, h:CGFloat){
//
//        let x:Int = cPos % 4
//        let y:Int = cPos / 4
//        iv.frame = CGRect(x: CGFloat(x)*w, y: CGFloat(y)*h, width: w, height: h-30)
//    }
    
    func setBlockPosition(rect:CGRect){
        let x = center.midX
        let y = center.midY
        iv.frame = CGRect(x: rect.midX * x, y: rect.midY * y, width: rect.width * center.width , height: rect.height * center.height)
        
        
    }
    
    func setImage(){
        iv.image = rawImg
 
    }
}
