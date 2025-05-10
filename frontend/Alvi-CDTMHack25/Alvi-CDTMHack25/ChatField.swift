//
//  Untitled.swift
//  Alvi-CDTMHack25
//
//  Created by Max Rosenblattl on 10.05.25.
//

import SwiftUI

struct ChatReplyBubble: View {
    @Binding var text: String
    let icon: Image         

    var iconSize: CGFloat = 50
    var background: Color = Color(.systemGray6)

    var body: some View {
        HStack(spacing: 10) {
            icon
                .resizable()                      // now the method exists
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)

            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(background)
        )
    }
}
