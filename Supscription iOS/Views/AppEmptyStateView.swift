//
//  AppEmptyStateView.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/20/26.
//

import SwiftUI

struct AppEmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("BrandPink").opacity(0.14),
                                Color("BrandPurple").opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(.primary.opacity(0.05), lineWidth: 1)
                    )
                    .frame(width: 116, height: 116)

                Image(systemName: systemImage)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("BrandPink"), Color("BrandPurple")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 10) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 320)

            Button(actionTitle) {
                action()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Color("BrandPink"))
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Subscriptions Empty") {
    AppEmptyStateView(
        systemImage: "rectangle.stack.badge.plus",
        title: "Start Tracking Your Subscriptions",
        message: "Add your first subscription to keep recurring payments, renewals, and reminders in one place.",
        actionTitle: "Add Subscription",
        action: {}
    )
}

#Preview("Dashboard Empty") {
    AppEmptyStateView(
        systemImage: "chart.bar.doc.horizontal",
        title: "Your Spending Story Starts Here",
        message: "Add a subscription first, then come back to see your monthly totals, categories, and upcoming renewals.",
        actionTitle: "Add Subscription",
        action: {}
    )
}
