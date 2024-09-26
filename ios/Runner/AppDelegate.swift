import UIKit
import Flutter

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

  override func startGeospatialARCoreSession(completion: @escaping (Coordinate) -> Void) {
    DispatchQueue.main.async {
        let contentView = ContentView(onCoordinateSelected: { coordinate in
                // Once coordinate is selected, call the completion handler
                completion(coordinate)
                
                // Dismiss the UIHostingController (if needed)
                if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                    rootViewController.dismiss(animated: true, completion: nil)
                }
            })
            
            // Create and present UIHostingController
            let hostingController = UIHostingController(rootView: contentView)
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(hostingController, animated: true, completion: nil)
            }
    }
  }
}
