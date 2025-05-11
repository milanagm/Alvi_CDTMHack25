//
//  WelcomeView.swift
//  Alvi-CDTMHack25
//
//  Created by Max Rosenblattl on 10.05.25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var message = "Thanks for sharing that, Milana 💛 Sounds like you're doing exactly the right thing by getting it checked out. To get started, could you please tap your insurance card with your phone now? That way I can read the info and we’re one step closer to being all set! 🪄📲"
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
                    message = "Perfect, thank you Milana! ✨ I see you're with Techniker Krankenkasse — everything synced just fine 🧾 Since you mentioned your heart has been racing in the evenings, could you share any heart rate data from your Apple Watch or Health app? That might really help the doctor! ❤️⌚"
                    showBottomButton = true
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(Color.clear)
                }

                if showBottomButton {
                    NavigationLink {
                        ContentView()
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
