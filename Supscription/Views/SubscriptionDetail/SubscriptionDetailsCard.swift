//
//  SubDetailsCard.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct SubscriptionDetailsCard: View {
    let subscription: Subscription

    var body: some View {
        VStack(spacing: 0) {
            // Category
            SubscriptionDetailRow(
                icon: "tag.fill",
                title: "Category",
                value: subscription.displayCategory,
                iconColor: .purple
            )

            // Website — only shown if present
            if let urlString = subscription.accountURL,
               let url = URL(string: "https://\(urlString)") {
                Divider().padding(.leading, 46)

                Link(destination: url) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.blue)
                                .frame(width: 32, height: 32)
                            Image(systemName: "safari")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                        }

                        Text("Website")
                            .font(.callout)
                            .foregroundStyle(.primary)

                        Spacer()

                        HStack(spacing: 4) {
                            Text(urlString)
                                .font(.callout.weight(.medium))
                                .foregroundStyle(.primary)
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                }
            }
        }
        .cardBackground()
    }
}
