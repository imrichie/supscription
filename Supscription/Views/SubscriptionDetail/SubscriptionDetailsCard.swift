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
                icon: "folder.fill",
                title: "Category",
                value: subscription.displayCategory,
                iconColor: .purple
            )

            // Website — only shown if present
            if let urlString = subscription.accountURL,
               let url = URL(string: "https://\(urlString)") {
                Divider().padding(.leading, 36)

                Link(destination: url) {
                    HStack {
                        Label {
                            Text("Website")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        } icon: {
                            Image(systemName: "link")
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 24, height: 24)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text(urlString)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "arrow.up.right.square")
                                .font(.caption)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.vertical, 6)
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
