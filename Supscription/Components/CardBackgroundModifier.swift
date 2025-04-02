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
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .windowBackgroundColor))
            )
    }
}

extension View {
    func cardBackground(alignment: Alignment = .center) -> some View {
        self.modifier(CardBackgroundModifier(alignment: alignment))
    }
}
