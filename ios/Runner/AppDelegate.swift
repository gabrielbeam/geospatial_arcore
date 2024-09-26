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
            // Create a SwiftUI ContentView and handle the coordinate selection
            let contentView = ContentView(onCoordinateSelected: { coordinate in
                // Once coordinate is selected, pass it back using the completion handler
                completion(.success(coordinate))
                
                // Dismiss the presented SwiftUI view (if necessary)
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootViewController = scene.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true, completion: nil)
                }
            })
            let hostingController = UIHostingController(rootView: contentView)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = scene.windows.first?.rootViewController {
                rootViewController.present(hostingController, animated: true, completion: nil)
            }
        }
  }
}
