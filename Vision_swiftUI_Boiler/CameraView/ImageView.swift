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
    var blocks: [ImageBlock] = []
    let letters:[Character] = ["X", "M", "W", "Z", "A", "P", "T", "K", "E", "N", "U", "C", "D", "L", "S", "B"]
    //let letters:[Character] = ["S", "B", "P", "X"]
    
    var score: String?
    
   
    
    init(score: String) {
        super.init(frame: .zero)
        self.score = score
       
        sourceImg = UIImage(named:"tester.png")
        // 2
       // outputImg = sourceImg
       
//
//
//
//
//        addSubview(imgView!)
//        NSLayoutConstraint.activate([
//            imgView!.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            imgView!.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            imgView!.topAnchor.constraint(equalTo: topAnchor, constant: 20),
//            imgView!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
//        ])
        var p = 0
        for letter in letters{
            
//                let iv = UIImageView(frame: (CGRect(x: x, y: y, width: w / 4 , height: h / 4)))
           // let im = UIImage(named:"\(letter).png")
            let im = generateQRCode(from: "\(letter)")
            let iv = UIImageView(image: im)
            iv.contentMode = .scaleAspectFit
            iv.alpha = 1
            var imageBlock = ImageBlock(iv: iv, rawImg: im!,  letter: letter)
                
               
            self.addSubview(imageBlock.iv)
            
           
            imageBlock.positionBlock(pos:p)
            
            imageBlock.setImage()
            blocks.append(imageBlock)
            p += 1
            
            
        }
        self.backgroundColor = .white
    }
        
    override func layoutSubviews() {
        
            super.layoutSubviews()
//        for v in subviews{
//            v.removeFromSuperview()
//        }
        print("frooroorooroom")
        backgroundColor = .white
        let w = frame.width / 4
        let h = frame.height / 4
        for block in blocks{
           
            block.resizeBlock(w: w, h: h)
            print(block.cPos)
           // blocks.append(block)
          
        }
       
        
       
           // addSubview(imgView!)
            //addSubview(imgView2)
          //  imgView2.image = outputImg
       
        
            
        }
    
    
    
    func sortPositions(){
       // print(score)
        let w = frame.width/4
        let h = frame.height/4
       
        if let input = score{
//            var inc = 0
//            for s in input{
//                let indexBlock = blocks.firstIndex { $0.letter == s}
//                if let ind = indexBlock{
//                    print("index: \(String(describing: ind)), \(blocks[ind].letter), \(blocks[ind].cPos)")
//
//                    blocks[ind].positionBlock(pos: inc)
//                    blocks[ind].resizeBlock(w: w, h: h)
//                    //print(blocks[i ?? 0].cPos)
//                    // self.update
//
//                }
//                inc += 1
//            }
//        }
            for index in 0..<blocks.count  {
                let s = blocks[index].letter
                if let firstIndex = input.firstIndex(of: s) {
                    let pos: Int = input.distance(from: input.startIndex, to: firstIndex)
                    blocks[index].positionBlock(pos: pos)
                    //block.positionBlock(pos: index)
                    blocks[index].resizeBlock(w: w, h: h)
                    
                    bringSubviewToFront(blocks[index].iv)
                    blocks[index].iv.alpha = 1
                }
                else {
                    print("symbol not found")
                    //blocks[index].iv.alpha = 0
                }
                
                
            }
            
        }
        
        
        
//        for block in blocks{
//            print("\(block.cPos),\(block.letter)")
//            block.resizeBlock(w: w, h: h)
//           // blocks.append(block)
//          
//        }
       // self.subviews.removeAll()
        
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
    
    
    func filterImg(){
        let context = CIContext(options: nil)
        //print("foofoofoofoo")
       // print(score)
       
//        cScore = cScore + (score ?? 0)
//        if(cScore < 1){
//            cScore = 1
//        }
        
        if let currentFilter = CIFilter(name: "CIPixellate") {
           
            let beginImage = CIImage(image: sourceImg!)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            currentFilter.setValue(1, forKey: kCIInputScaleKey)
            currentFilter.setValue(CIVector(x: (sourceImg?.size.width ?? 0)/2,y: (sourceImg?.size.height ?? 0)/2), forKey: kCIInputCenterKey)
            
            if let output = currentFilter.outputImage {
                if let cgimg = context.createCGImage(output, from: output.extent) {
                    outputImg = UIImage(cgImage: cgimg)
                   // imgView?.frame = self.frame
                   // imgView?.image = outputImg
                   
                   // imgView?.contentMode = .center
                   
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
    @Binding var score:String
  
    func makeUIView(context: Context) -> ImageView {
        let view = ImageView(score: score)

        // Do some configurations here if needed.
        return view
    }
    
    init(score: Binding<String>){
        self._score = score
    }
    
    func updateUIView(_ uiView: ImageView, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
        
        uiView.score = score
       // uiView.label.text = ":\(score)"
       // uiView.filterImg()
        uiView.sortPositions()
        uiView.setNeedsDisplay()
        
    }
}

struct ImageBlock{
    
    var iv:UIImageView
    var rawImg: UIImage
    var letter:Character
    var cPos:Int = 0
   
    mutating func positionBlock(pos:Int){
        cPos = pos
       
    }
    
    func resizeBlock( w:CGFloat, h:CGFloat){
       
        let x:Int = cPos % 4
        let y:Int = cPos / 4
        iv.frame = CGRect(x: CGFloat(x)*w, y: CGFloat(y)*h, width: w, height: h-30)
    }
    
    func setImage(){
        iv.image = rawImg
 
    }
}
