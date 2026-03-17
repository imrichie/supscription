//
//  ScoreCardView.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/16/26.
//

import SwiftUI

struct ScoreCardView: View {
    let title: String
    let value: String
    let subtitle: String
    let systemImage: String
    let cardColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Icon badge
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.white.opacity(0.18))
                    .frame(width: 40, height: 40)

                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }

            Spacer()

            // Value
            Text(value)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            // Title
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))

            // Subtitle
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 160, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardColor)
        )
    }
}
