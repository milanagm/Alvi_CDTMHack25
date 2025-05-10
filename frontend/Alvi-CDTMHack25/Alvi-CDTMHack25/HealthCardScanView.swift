//
//  HealthCardScanView.swift
//  Alvi-CDTMHack25
//
//  Created by Max Rosenblattl on 10.05.25.
//

import SwiftUI

struct HealthCardScanView: View {
    @StateObject private var model = HealthCardScanModel()

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "wave.3.right")
                .font(.system(size: 60))
                .accessibilityHidden(true)

            Text(model.status)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if let iccsn = model.iccsn {
                Text("ICCSN: \(iccsn)")
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal)
            }

            Button("Gesundheits­karte scannen") {
                model.startScan()
            }
            .buttonStyle(.borderedProminent)
            .disabled(model.status.hasPrefix("Warte"))   // prevent double-tap
        }
        .padding()
        .navigationTitle("eGK Scanner")
    }
}
