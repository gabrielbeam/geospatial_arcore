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
import CoreGraphics
import CoreLocation
import Foundation
import RealityKit
import simd

/// Model object for using the Geospatial API and placing Geospatial anchors.
class GeospatialManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var apiKey: String
    @Published var horizontalAccuracyLowerLimitInMeters: Int64
    @Published var cameraTimeoutInSeconds: Int64
    var onCoordinateUpdate: ((Coordinate) -> Void)?
  /// Different types of Geospatial anchors you can place with the app.

  private enum Constants {
    /// User defaults key for storing privacy notice acceptance.
    static let privacyNoticeUserDefaultsKey = "privacy_notice_acknowledged"
    /// User defaults key for storing saved anchors.
    static let savedAnchorsUserDefaultsKey = "anchors"
    /// Maximum number of anchors you can place at one time.
    static let maxAnchorCount = 20
    /// Horizontal accuracy threshold (meters) for being considered localized with "high accuracy".
    static let horizontalAccuracyLowThreshold: CLLocationAccuracy = 10
    /// Horizontal accuracy threshold (meters) for being considered to lose "high accuracy"
    /// localization.
    static let horizontalAccuracyHighThreshold: CLLocationAccuracy = 20
    /// Orientation yaw accuracy threshold (degrees) for being considered localized with
    /// "high accuracy".
    static let orientationYawAccuracyLowThreshold: CLLocationDirectionAccuracy = 15
    /// Orientation yaw accuracy threshold (degrees) for being considered to lose "high accuracy"
    /// localization.
    static let orientationYawAccuracyHighThreshold: CLLocationDirectionAccuracy = 25
    /// Give up localizing with high accuracy after 3 minutes.
    static let localizationFailureTime: TimeInterval = 180
  }

  @Published var trackingLabel = ""
  @Published var statusLabel = ""
  @Published var tapScreenVisible = false
  @Published var clearAnchorsVisible = false
  @Published var showPrivacyNotice = !UserDefaults.standard.bool(
    forKey: Constants.privacyNoticeUserDefaultsKey)
  @Published var showVPSUnavailableNotice = false
    
    @Published var coordinate: Coordinate? {
       didSet {
           // Whenever the coordinate is updated, trigger the callback
           if let coordinate = coordinate {
               onCoordinateUpdate?(coordinate)
           }
       }
   }

  let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
  private var locationManager: CLLocationManager?
  private var garSession: GARSession?

  private var pendingFutures: [UUID: GARFuture] = [:]
  private var anchors: [GARAnchor] = []
  var earthTracking = false
  var highAccuracy = false
  private var addedSavedAnchors = false
  private var localizationFailed = false
  private var lastStartDate: Date? = nil
  private var resolveErrorMessage: String? = nil

    init(apiKey: String,
        horizontalAccuracyLowerLimitInMeters: Int64,
        cameraTimeoutInSeconds: Int64) {
        
        self.apiKey = apiKey
        self.horizontalAccuracyLowerLimitInMeters = horizontalAccuracyLowerLimitInMeters
        self.cameraTimeoutInSeconds = cameraTimeoutInSeconds
        
        super.init()
        
        self.showPrivacyNotice = showPrivacyNotice

        

        if !showPrivacyNotice {
            setupARSession()
        }
    }

  private func updateLocalizationState(_ garFrame: GARFrame) {
    guard let earth = garFrame.earth, let lastStartDate else { return }

    if earth.earthState != .enabled {
      localizationFailed = true
      return
    }

    guard let geospatialTransform = earth.cameraGeospatialTransform,
      earth.trackingState == .tracking
    else {
      earthTracking = false
      return
    }

    earthTracking = true
    let now = Date()

    if highAccuracy {
      if geospatialTransform.horizontalAccuracy > Constants.horizontalAccuracyHighThreshold
        || geospatialTransform.orientationYawAccuracy
          > Constants.orientationYawAccuracyHighThreshold
      {
        highAccuracy = false
        self.lastStartDate = now
      }
      return
    }

    if geospatialTransform.horizontalAccuracy < Constants.horizontalAccuracyLowThreshold
      && geospatialTransform.orientationYawAccuracy < Constants.orientationYawAccuracyLowThreshold
    {
      highAccuracy = true
    } else if now.timeIntervalSince(lastStartDate) >= Constants.localizationFailureTime {
      localizationFailed = true
    }
  }

  private static func string(from earthState: GAREarthState) -> String {
    switch earthState {
    case .errorInternal:
      return "ERROR_INTERNAL"
    case .errorNotAuthorized:
      return "ERROR_NOT_AUTHORIZED"
    case .errorResourceExhausted:
      return "ERROR_RESOURCE_EXHAUSTED"
    default:
      return "ENABLED"
    }
  }

  private func updateTrackingLabel(_ garFrame: GARFrame) {
    guard let earth = garFrame.earth else { return }

    if localizationFailed {
      if earth.earthState != .enabled {
        trackingLabel = "Bad EarthState: \(GeospatialManager.string(from: earth.earthState))"
      } else {
        trackingLabel = ""
      }
      return
    }

    guard let geospatialTransform = earth.cameraGeospatialTransform,
      earth.trackingState == .tracking
    else {
      trackingLabel = "Not tracking."
      return
    }

    trackingLabel = String(
      format:
        "LAT/LONG: %.6f°, %.6f°\n    ACCURACY: %.2fm\nALTITUDE: %.2fm\n    ACCURACY: %.2fm\n"
        + "ORIENTATION: [%.1f, %.1f, %.1f, %.1f]\n    YAW ACCURACY: %.1f°",
      arguments: [
        geospatialTransform.coordinate.latitude, geospatialTransform.coordinate.longitude,
        geospatialTransform.horizontalAccuracy, geospatialTransform.altitude,
        geospatialTransform.verticalAccuracy, geospatialTransform.eastUpSouthQTarget.vector[0],
        geospatialTransform.eastUpSouthQTarget.vector[1],
        geospatialTransform.eastUpSouthQTarget.vector[2],
        geospatialTransform.eastUpSouthQTarget.vector[3],
        geospatialTransform.orientationYawAccuracy,
      ])
  }
    
    func isHorizontalAccuracyLowerLimitReached(_ garFrame: GARFrame) -> Bool {
        guard let earth = garFrame.earth else { return false }
        if localizationFailed {
          return false
        }

        guard let geospatialTransform = earth.cameraGeospatialTransform,
          earth.trackingState == .tracking
        else {
          return false
        }
        return geospatialTransform.horizontalAccuracy < Double(self.horizontalAccuracyLowerLimitInMeters)
    }
    
    func updateCoordinateAndCloseView(_ garFrame: GARFrame?) {
        guard let earth = garFrame?.earth else { return }

        if localizationFailed {
          return
        }

        guard let geospatialTransform = earth.cameraGeospatialTransform,
          earth.trackingState == .tracking
        else {
          return
        }
        
        if geospatialTransform.horizontalAccuracy < Double(self.horizontalAccuracyLowerLimitInMeters) {
            self.coordinate = Coordinate(latitude: geospatialTransform.coordinate.latitude, longitude: geospatialTransform.coordinate.longitude, altitude: geospatialTransform.altitude)
        }
    }

  /// Feeds the latest `ARFrame` to the `GARSession` and updates the UI state.
  func update(_ frame: ARFrame) -> GARFrame? {
    guard let garSession, !localizationFailed else { return nil }
    guard let garFrame = try? garSession.update(frame) else { return nil }

    updateLocalizationState(garFrame)
    updateTrackingLabel(garFrame)

    return garFrame
  }

  /// Called when the user accepts the privacy notice.
  func acceptPrivacyNotice() {
    UserDefaults.standard.setValue(true, forKey: Constants.privacyNoticeUserDefaultsKey)
    setupARSession()
  }

  private func setupARSession() {
    let configuration = ARWorldTrackingConfiguration()
    configuration.worldAlignment = .gravity
    // Optional. It will help the dynamic alignment of terrain anchors on ground.
    configuration.planeDetection = .horizontal
    arView.session.run(configuration)

    locationManager = CLLocationManager()
    // This will cause `locationManagerDidChangeAuthorization()` to be called asynchronously on the
    // main thread. After obtaining location permission, we will set up the ARCore session.
    locationManager?.delegate = self
  }

  private func setErrorStatus(_ message: String) {
    statusLabel = message
    tapScreenVisible = false
    clearAnchorsVisible = false
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    switch manager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      if manager.accuracyAuthorization != .fullAccuracy {
        setErrorStatus("Location permission not granted with full accuracy.")
        return
      }
      setupGARSession()
      // Request device location for checking VPS availability.
      manager.requestLocation()
    case .notDetermined:
      // The app is responsible for obtaining the location permission prior to configuring the
      // ARCore session. ARCore will not cause the location permission system prompt.
      manager.requestWhenInUseAuthorization()
    default:
      setErrorStatus("Location permission denied or restricted.")
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last, let garSession {
      garSession.checkVPSAvailability(coordinate: location.coordinate) { availability in
        if availability != .available {
          self.showVPSUnavailableNotice = true
        }
      }
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    print("Location manager failed: \(error)")
  }

  private func setupGARSession() {
    guard garSession == nil else { return }

    let session: GARSession
    do {
      session = try GARSession(apiKey: self.apiKey, bundleIdentifier: nil)
    } catch let error as NSError {
      setErrorStatus("Failed to create GARSession: \(error.code)")
      return
    }

    if !session.isGeospatialModeSupported(.enabled) {
      setErrorStatus("The Geospatial API is not supported on this device.")
      return
    }

    let configuration = GARSessionConfiguration()
    configuration.geospatialMode = .enabled
    var error: NSError?
    session.setConfiguration(configuration, error: &error)
    if let error {
      setErrorStatus("Failed to configure GARSession: \(error.code)")
    }

    garSession = session
    lastStartDate = Date()
  }
}
