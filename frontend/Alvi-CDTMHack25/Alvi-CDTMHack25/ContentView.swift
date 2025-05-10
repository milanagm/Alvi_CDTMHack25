//
//  ContentView.swift
//  Alvi-CDTMHack25
//
//  Created by Max Rosenblattl on 10.05.25.
//

import HealthKitUI
import Spezi
import SpeziHealthKit
import SwiftUI
import SpeziHealthKitUI

let allTypes: Set = [
    HKQuantityType.workoutType(),
    HKQuantityType(.activeEnergyBurned),
    HKQuantityType(.distanceCycling),
    HKQuantityType(.distanceWalkingRunning),
    HKQuantityType(.distanceWheelchair),
    HKQuantityType(.heartRate)
    // blood pressure, weight, height,
]

struct UploadView: View {
    @State private var isCameraPresented = false
    @State private var isDocumentPickerPresented = false
    @State private var isImagePickerPresented = false  // Bild-Picker direkt hier steuern
    @State private var pickedImage: UIImage? = nil

    var body: some View {
        VStack {
            // Avatar in einem Kreis anzeigen
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 150, height: 150)
                
                Image("Alvi_smiling") // Dein Avatar-Bild
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
            .padding()

            // Sprechblase und Text
            HStack {
                Text("Help me to be your perfect assistant and gather some information...")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(maxWidth: 250)
                
                Spacer()
            }
            .padding()

            // Buttons
            VStack(spacing: 20) {
                // Button 1: Take a photo
                Button(action: {
                    isCameraPresented.toggle() // Kamera Modal öffnen
                }) {
                    Text("Take a photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Button 2: Upload document
                Button(action: {
                    isDocumentPickerPresented.toggle() // Dokumenten-Picker Modal öffnen
                }) {
                    Text("Upload document")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Button 3: Select picture (öffnet sofort die Fotogalerie)
                Button(action: {
                    isImagePickerPresented.toggle() // Bild-Auswahl Modal öffnen
                }) {
                    Text("Select picture")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color.white)  // Hintergrund auf weiß setzen
        .sheet(isPresented: $isCameraPresented) {
            CameraView(isImagePicked: .constant(false), pickedImage: $pickedImage)
        }
        .sheet(isPresented: $isDocumentPickerPresented) {
            DocumentPickerView(selectedDocumentURL: .constant(nil))
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(selectedImage: $pickedImage) // Direkt der Bild-Picker
        }
}

struct ContentView: View {
    @State var authenticated = false
    @State var trigger = false

    @HealthKitQuery(.heartRate, timeRange: .last(months: 3))
    private var heartRateSamples

    var body: some View {
        Button("Access health data") {
            // OK to read or write HealthKit data here.
        }
        .disabled(!authenticated)

        // If HealthKit data is available, request authorization
        // when this view appears.
        .onAppear() {

            // Check that Health data is available on the device.
            if HKHealthStore.isHealthDataAvailable() {
                // Modifying the trigger initiates the health data
                // access request.
                trigger.toggle()
            }
        }

        // Requests access to share and read HealthKit data types
        // when the trigger changes.
        .healthDataAccessRequest(store: HKHealthStore(),
                                 shareTypes: allTypes,
                                 readTypes: allTypes,
                                 trigger: trigger) { result in
            switch result {

            case .success(_):
                authenticated = true
            case .failure(let error):
                // Handle the error here.
                fatalError("*** An error occurred while requesting authentication: \(error) ***")
            }
        }

        /* Health Chart Example
        HealthChart {
            HealthChartEntry($heartRateSamples, drawingConfig: .init(mode: .line, color: .red))
        }
        */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
