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

/*
 {
   "unit": "bpm",
   "level": 109,
   "method": "Apple HealthKit",
   "datetime": "2025-05-08 10:37",
   "measurement_type": "heart rate"
 },

 */

private struct HeartRateDatum: Codable {
    let level: Double
    let datetime: Date
    var method: String = "Apple HealthKit"
    var unit = "bpm"
    var measurement_type = "heart rate"
//    let end: Date
//    let deviceName: String?
//    let motionContext: Int?

    init(sample: HKQuantitySample) {
        level = sample.quantity
                      .doubleValue(for: .count()
                      .unitDivided(by: .minute()))
        datetime = sample.startDate
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
    @State private var message = "Perfect, thank you Milana! ✨ I see you're with Techniker Krankenkasse — everything synced just fine 🧾 Since you mentioned your heart has been racing in the evenings, could you share any heart rate data from your Apple Watch or Health app? That might really help the doctor! ❤️⌚"

    @HealthKitQuery(.heartRate, timeRange: .last(days: 1))
    private var heartRateSamples

    var body: some View {
        NavigationStack {
            VStack {
                ChatReplyBubble(
                    text: $message,
                    icon: Image("alvi-idle")
                )
                .padding()

                Spacer()

                NavigationLink(
                    destination: UploadView(),
                    isActive: $authenticated,
                    label: { EmptyView() }
                )

                Button("") {
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

                .healthDataAccessRequest(store: HKHealthStore(),
                                         shareTypes: allTypes,
                                         readTypes: allTypes,
                                         trigger: trigger) { result in
                    switch result {

                    case .success(_):
                        do {
                            let json = try heartRateSamplesJSON(from: Array(heartRateSamples))
                            sendDataToAPI(json)
                        } catch {
                            print("error parsing")
                        }
                        authenticated = true
                    case .failure(let error):
                        // Handle the error here.
                        fatalError("*** An error occurred while requesting authentication: \(error) ***")
                    }
                }
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
            "patientId": "81d40b06-601d-4f43-91bf-539933e1f6a6",
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
