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

private struct HeartRateDatum: Codable {
    let uuid: UUID
    let bpm: Double
//    let start: Date
//    let end: Date
//    let deviceName: String?
//    let motionContext: Int?

    init(sample: HKQuantitySample) {
        uuid  = sample.uuid
        bpm   = sample.quantity
                     .doubleValue(for: .count()
                     .unitDivided(by: .minute()))     //  “count/min”  ➜ beats per minute
//        start = sample.startDate
//        end   = sample.endDate
//        deviceName = sample.device?.name
//        motionContext = sample.metadata?[HKMetadataKeyHeartRateMotionContext] as? Int
    }
}


let allTypes: Set = [
    HKQuantityType.workoutType(),
    HKQuantityType(.activeEnergyBurned),
    HKQuantityType(.distanceCycling),
    HKQuantityType(.distanceWalkingRunning),
    HKQuantityType(.distanceWheelchair),
    HKQuantityType(.heartRate)
    // blood pressure, weight, height,
]

struct ContentView: View {
    @State var authenticated = false
    @State var trigger = false

    @HealthKitQuery(.heartRate, timeRange: .last(days: 1))
    private var heartRateSamples

    var body: some View {
        Button("Access health data") {
//            print(heartRateSamples.description)
            do {
                let json = try heartRateSamplesJSON(from: Array(heartRateSamples))
                sendDataToAPI(json)
            } catch {
                print("error parsing")
            }
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

    func heartRateSamplesJSON(from samples: [HKQuantitySample]) throws -> String {
        let datums   = samples.map(HeartRateDatum.init(sample:))
        let encoder  = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601          // pick the format you need
        encoder.outputFormatting    = [.prettyPrinted]   // optional
        let jsonData = try encoder.encode(datums)        // <— encodes *array*, not envelope
        return String(decoding: jsonData, as: UTF8.self)
    }

    // Funktion zum Senden der HealthKit-Daten an das Endpoint
    func sendHealthDataToEndpoint() {
        // Sende die rohen Daten direkt
        sendDataToAPI("\(heartRateSamples)")
    }

    // Daten an das API-Endpunkt senden
    func sendDataToAPI(_ jsonData: String) {
        guard let url = URL(string: "https://cdtmhack.vercel.app/api/post_health_data") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("AYBXFG3VBOSXCPIJARmjGfyfB8dI97vJ", forHTTPHeaderField: "x-vercel-protection-bypass")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Ensure the JSON structure matches exactly what the API expects
        let finalJsonData = """
        {
            "patientId": "6a53a6cb-86b8-41d1-bc28-84e8de22cd1d",
            "patientData": \(jsonData)
        }
        """
        
        request.httpBody = Data(finalJsonData.utf8)
        print(finalJsonData)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print(data, response, error)

            if let error = error {
                print("Error sending data: \(error)")
                return
            }
            if let data = data, let response = try? JSONSerialization.jsonObject(with: data, options: []) {
                print("Response: \(response)")
            }
        }
        task.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
