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
]

struct ContentView: View {
    @State var authenticated = false
    @State var trigger = false

    @HealthKitQuery(.heartRate, timeRange: .currentYear)
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

#Preview {
    ContentView()
}
