//
//  WelcomeView.swift
//  Alvi-CDTMHack25
//
//  Created by Max Rosenblattl on 10.05.25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var message = "Hi, I'm Alvi! Your companion for your appointment tomorrow at 13:30. \nStart by tapping your European Health Insurance card on the back of your phone."
    @State private var showBottomButton = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ChatReplyBubble(
                    text: $message,
                    icon: Image("alvi-idle")
                )
                .padding()

                Spacer()

                Button(action: {
                    message = "Thank you, Sven! Next let's gather all your medical documents"
                    showBottomButton = true
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.clear)
                }

                if showBottomButton {
                    NavigationLink {
                        UploadView()
                    } label: {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                            .padding()
                    }
                    .transition(.blurReplace)
                }
            }
        }
    }
}


#Preview {
    WelcomeView()
}
