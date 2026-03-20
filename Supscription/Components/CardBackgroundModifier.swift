//
//  CardBackgroundModifier.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/1/25.
//

import SwiftUI

struct CardBackgroundModifier: ViewModifier {
    var alignment: Alignment

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: alignment)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(.separatorColor).opacity(0.4), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

extension View {
    func cardBackground(alignment: Alignment = .center) -> some View {
        self.modifier(CardBackgroundModifier(alignment: alignment))
    }
}
