//
//  HealthCardScanModel.swift
//  Alvi-CDTMHack25
//
//  Created by Max Rosenblattl on 10.05.25.
//

import SwiftUI
import CardReaderAccess
import HealthCardAccess           // commands, responses, file system
import NFCCardReaderProvider      // Core NFC glue

@MainActor
final class HealthCardScanModel: NSObject, ObservableObject {

    @Published var status: String = "Bereit zum Scannen"
    @Published var iccsn: String?

    /// Public entry point the button in the view will call
    func startScan() {
        Task { await runSession() }
    }

    // MARK: – Private helpers

    private func runSession() async {
        do {
            // 1) Open a structured-concurrency NFC session that waits
            //    until the user places a card on the phone.
            let healthCard = try await NFCHealthCardSession.open()      // new since OHCK 5.6 🎉

            // 2) Build an APDU that reads the ICCSN elementary file (fixed SFI 0x02).
            let readICCSN = try HealthCardCommand.Read
                .readFileCommand(with: EgkFileSystem.EF.iccsn.sfid!, ne: 32)

            // 3) Transmit the command through the session’s connected card.
            let response = try await readICCSN.transmit(to: healthCard)
            guard response.responseStatus == .success, let data = response.data else {
                throw HealthCard.Error.operational
            }

            iccsn  = data.hexString()
            status = "ICCSN gelesen ✓"

        } catch {
            status = "Fehler: \(error.localizedDescription)"
        }
    }
}
