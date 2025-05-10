//
//  AlviAppDelegate.swift
//  Alvi-CDTMHack25
//
//  Created by Max Rosenblattl on 10.05.25.
//

import Spezi
import HealthKit
import SwiftUI
import SpeziHealthKit

class AlviAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration(standard: AlviStandard()) {
            if HKHealthStore.isHealthDataAvailable() {
                HealthKit {
                    CollectSample(.heartRate, continueInBackground: true)
                }
            }
        }
    }
}
