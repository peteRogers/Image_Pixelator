//
//  ContentView.swift
//  Vision_swiftUI_Boiler
//
//  Created by Peter Rogers on 07/12/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var score:Float = 0
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


