//
// Copyright 2024 Google LLC. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import ARCore
import ARKit
import RealityKit
import SwiftUI
import simd

/// SwiftUI wrapper for an `ARView` and all rendering code.
struct ARViewContainer: UIViewRepresentable {
  let manager: GeospatialManager
  let cameraTimeoutInSeconds: Int64

  /// Coordinator to act as `ARSessionDelegate` for `ARView`.
  class Coordinator: NSObject, ARSessionDelegate {
    private let manager: GeospatialManager
    private var latestGarFrame: GARFrame?
    private var isTimeoutStarted: Bool = false

    init(_ manager: GeospatialManager) {
      self.manager = manager
      super.init()
      manager.arView.session.delegate = self
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
      guard let garFrame = manager.update(frame) else { return }
      latestGarFrame = garFrame
        if (!isTimeoutStarted && manager.isHorizontalAccuracyLowerLimitReached(garFrame)) {
            isTimeoutStarted = true
            startTimeoutToGetCoordinate()
        }
    }
      private func startTimeoutToGetCoordinate() {
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(manager.cameraTimeoutInSeconds))) { [weak self] in
              self?.manager.updateCoordinateAndCloseView(self?.latestGarFrame)
          }
      }
  }

  func makeUIView(context: Context) -> ARView {
    return manager.arView
  }

  func updateUIView(_ uiView: ARView, context: Context) {}

  func makeCoordinator() -> Coordinator {
    return Coordinator(manager)
  }
}
