//
//  AudioView.swift
//  Alvi-CDTMHack25
//
//  Created by Max Rosenblattl on 11.05.25.
//

import SwiftUI

struct AudioView: View {
    @State private var isRecording = false       // current state
    @State private var message = "Hey Milana 🌼 I'm Alvi — your friendly little helper elf from Avi's general practice! I'm here to get everything ready for your appointment tomorrow at 2pm 🧚‍♀️ Before we dive in, could you let me know what brings you in to see the doctor? That helps me prepare everything just right!"

    @State private var navigateToWelcome = false  // <-- trigger

    private let size: CGFloat = 120              // overall diameter

    var body: some View {
        NavigationStack {
            VStack {
                ChatReplyBubble(
                    text: $message,
                    icon: Image("alvi-idle")
                )
                .padding()

                Spacer()

                ZStack {
                    Circle()
                        .fill(isRecording ? Color.accentColor : Color(.systemGray5))
                        .frame(width: size, height: size)

                    Image(systemName: "mic.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(isRecording ? .white : .primary)
                        .scaleEffect(x: isRecording ? -1 : 1, y: 1) // ← “reversed”
                        .animation(.spring(response: 0.25, dampingFraction: 0.6),
                                   value: isRecording)
                }
                .contentShape(Circle())                  // entire circle is tappable
                .onTapGesture { isRecording.toggle() }

                NavigationLink(
                    destination: WelcomeView(),
                    isActive: $navigateToWelcome,
                    label: { EmptyView() }
                )
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    navigateToWelcome = true
                }
            }
        }
    }
}

#Preview {
    AudioView()
}
