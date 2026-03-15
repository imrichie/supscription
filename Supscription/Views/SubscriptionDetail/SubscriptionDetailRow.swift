//
//  DetailRow.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct SubscriptionDetailRow: View {
    var icon: String
    var title: String
    var value: String
    var iconColor: Color = .blue

    var body: some View {
        HStack(spacing: 14) {
            // Shortcuts-style icon square: solid color fill, white symbol
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(title)
                .font(.callout)
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(.callout.weight(.medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 10)
    }
}
