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

    func startGeospatialARCoreSession(completion: @escaping (Result<Coordinate, Error>) -> Void) {
            // Switch to the main thread since UI updates must be done on the main queue
        DispatchQueue.main.async {
            // Create the UIHostingController
            let hostingController = UIHostingController(rootView: ContentView(
                onCoordinateSelected: { coordinate in
                    completion(.success(coordinate))
                }
            ))

            // Set the modal presentation style to full screen
            hostingController.modalPresentationStyle = .fullScreen
            
            // Present the hosting controller
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(hostingController, animated: true, completion: nil)
            }
        }
    }
}
