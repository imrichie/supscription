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
            .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 3)
    }
}

extension View {
    func cardBackground(alignment: Alignment = .center) -> some View {
        self.modifier(CardBackgroundModifier(alignment: alignment))
    }
}
