import UIKit
import Flutter
import SwiftUI

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, GeospatialARCoreApi {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window.rootViewController as! FlutterViewController

    GeospatialARCoreApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: self)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

    func startGeospatialARCoreSession(apiKey: String, horizontalAccuracyLowerLimitInMeters: Int64, cameraTimeoutInSeconds: Int64, showAdditionalDebugInfo: Bool, completion: @escaping (Result<Coordinate, Error>) -> Void) {
        DispatchQueue.main.async {
            let vpsCameraScreen = UIHostingController(rootView: ContentView(
                apiKey: apiKey, // Pass apiKey first
                horizontalAccuracyLowerLimitInMeters: horizontalAccuracyLowerLimitInMeters,
                cameraTimeoutInSeconds: cameraTimeoutInSeconds,
                showAdditionalDebugInfo: showAdditionalDebugInfo,
                onCoordinateSelected: { coordinate in
                    completion(.success(coordinate))
                }
            ))

            // Set the modal presentation style to full screen
            vpsCameraScreen.modalPresentationStyle = .fullScreen
            self.window?.rootViewController?.present(vpsCameraScreen, animated: true, completion: nil)
        }
    }
}
