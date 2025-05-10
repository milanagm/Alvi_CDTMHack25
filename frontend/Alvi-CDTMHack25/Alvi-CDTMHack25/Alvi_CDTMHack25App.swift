//
//  Alvi_CDTMHack25App.swift
//  Alvi-CDTMHack25
//
//  Created by Max Rosenblattl on 10.05.25.
//

import Spezi
import HealthKit
//import HealthKitDataSource
//import Questionnaires
import SwiftUI

@main
struct Alvi_CDTMHack25App: App {
    @ApplicationDelegateAdaptor(AlviAppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .spezi(appDelegate)
        }
    }
}
