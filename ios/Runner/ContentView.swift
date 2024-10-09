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

import SwiftUI

/// View for testing Geospatial localization, Streetscape Geometry and Geospatial anchors.
struct ContentView: View {
    var apiKey: String
    var horizontalAccuracyLowerLimitInMeters: Int64
    var cameraTimeoutInSeconds: Int64
    var showAdditionalDebugInfo: Bool
    var onCoordinateSelected: (Coordinate) -> Void
    
    @StateObject var manager: GeospatialManager
    @Environment(\.presentationMode) var presentationMode
    
    init(apiKey: String,
         horizontalAccuracyLowerLimitInMeters: Int64,
         cameraTimeoutInSeconds: Int64,
         showAdditionalDebugInfo: Bool,
         onCoordinateSelected: @escaping (Coordinate) -> Void) {
        self.apiKey = apiKey
        self.horizontalAccuracyLowerLimitInMeters = horizontalAccuracyLowerLimitInMeters
        self.cameraTimeoutInSeconds = cameraTimeoutInSeconds
        self.showAdditionalDebugInfo = showAdditionalDebugInfo
        self.onCoordinateSelected = onCoordinateSelected
        _manager = StateObject(wrappedValue: GeospatialManager(apiKey: apiKey,
                                                               horizontalAccuracyLowerLimitInMeters: horizontalAccuracyLowerLimitInMeters,
                                                               cameraTimeoutInSeconds: cameraTimeoutInSeconds))
    }
    
  
    private let font = Font.system(size: 14)
    private let boldFont = Font.system(size: 14, weight: .bold)
  
  var body: some View {
      VStack {
          HStack {
              Button {
                  onCoordinateSelected(Coordinate(latitude:0,longitude: 0, altitude: 0))
                  presentationMode.wrappedValue.dismiss()
              } label: {
                  Image(systemName: "xmark")
                      .foregroundColor(Color(.label))
                      .imageScale(/*@START_MENU_TOKEN@*/.medium/*@END_MENU_TOKEN@*/)
                      .frame(width:44, height: 20)
              }
              Text( "Scan surrounding")
                  .font(.system(size: 20))
                  .fontWeight(.semibold)
                  .frame(maxWidth: .infinity, alignment: .leading)
          }
          .padding([.top, .leading, .trailing]) // Default padding for top, leading, and trailing
          ZStack {
              ARViewContainer(manager: manager, cameraTimeoutInSeconds: cameraTimeoutInSeconds)
                  .ignoresSafeArea()
              VStack {
                  if (showAdditionalDebugInfo) {
                      ZStack(alignment: .leading) {
                          Rectangle()
                              .opacity(0.5)
                          Text(manager.trackingLabel)
                              .font(font)
                              .foregroundStyle(.white)
                              .lineLimit(6)
                              .multilineTextAlignment(.leading)
                      }
                      .frame(height: 140)
                      Spacer()
                  }
                  Spacer()
                  ZStack {
                      Rectangle()
                          .fill(Color(UIColor(red: 0x1D / 255.0, green: 0x0E / 255.0, blue: 0x40 / 255.0, alpha: 0.9)))
                          .frame(maxWidth: .infinity)
                          .frame(height: 60)
                          .cornerRadius(5)
                          .padding(.horizontal, 20)
                      Text("Please point your camera towards nearby buildings or road signs.")
                          .font(font)
                          .foregroundStyle(.white)
                          .lineLimit(2)
                          .multilineTextAlignment(.center)
                          .padding()
                  }
                  .padding(.bottom, 100)
              }
              
          }
      }
    .onAppear {
        manager.onCoordinateUpdate = { coordinate in
            // Do something with the coordinate here
            onCoordinateSelected(coordinate)
            presentationMode.wrappedValue.dismiss()
        }
    }    .alert("AR in the real world", isPresented: $manager.showPrivacyNotice) {
      Button {
        manager.acceptPrivacyNotice()
      } label: {
        Text("Get started")
      }
      Link("Learn more", destination: URL(string: "https://developers.google.com/ar/data-privacy")!)
    } message: {
      Text("To power this session, Google will process visual data from your camera.")
    }
    .alert("VPS not available", isPresented: $manager.showVPSUnavailableNotice) {
      Button {
      } label: {
        Text("Continue")
      }
    } message: {
      Text(
        "The Google Visual Positioning Service (VPS) is not available at your current "
          + "location. Location data may not be as accurate.")
    }
  }
}
