

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
  var score: ((String) -> Void)?

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
