//
//  ScoreCardView.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/10/26.
//

import SwiftUI

struct ScoreCardView: View {
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String
    let cardColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(cardColor)
                )

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.8))

                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cardColor.gradient)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(value). \(subtitle)")
    }
}

#Preview("Score Card") {
    ScoreCardView(
        title: "Monthly Spend",
        value: "$186.42",
        subtitle: "14 subscriptions",
        systemImage: "creditcard.fill",
        cardColor: .blue
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
