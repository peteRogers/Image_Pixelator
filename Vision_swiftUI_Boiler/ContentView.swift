//
//  ContentView.swift
//  Vision_swiftUI_Boiler
//
//  Created by Peter Rogers on 07/12/2022.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State private var score:[VNBarcodeObservation] = []
    var body: some View {
        ZStack{
            CameraView{
                score = $0
            
            }.overlay(
                RepresentedImageView(score: $score)
                    .foregroundColor(.red)
              )
              .edgesIgnoringSafeArea(.all)
        }
    }
}


