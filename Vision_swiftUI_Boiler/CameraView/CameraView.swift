

import SwiftUI
import UIKit
import Vision

struct CameraView: UIViewControllerRepresentable {
  var score: (([VNBarcodeObservation]) -> Void)?

  func makeUIViewController(context: Context) -> CameraViewController {
    let cvc = CameraViewController()
    cvc.score = score
    return cvc
  }

  func updateUIViewController(
    _ uiViewController: CameraViewController,
    context: Context
  ) {
  }
}
