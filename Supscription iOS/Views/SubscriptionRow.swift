//
//  SubscriptionRow.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI

struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 14) {
            logoView

            VStack(alignment: .leading, spacing: 5) {
                Text(subscription.accountName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(categoryLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    if subscription.remindToCancel {
                        Image(systemName: "bell.fill")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.accentColor.opacity(0.8))
                    }
                }
            }
            .layoutPriority(1)

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(frequencyLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var logoView: some View {
        ZStack {
            if let logoName = subscription.logoName,
               !logoName.isEmpty,
               let uiImage = loadLogoImage(named: logoName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(placeholderBackground)

                Text(subscription.accountName.prefix(1).uppercased())
                    .font(.headline.weight(.bold))
                    .foregroundStyle(placeholderForeground)
            }
        }
        .frame(width: 48, height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.primary.opacity(0.06), lineWidth: 0.8)
        )
    }

    private var frequencyLabel: String {
        guard let frequency = BillingFrequency(rawValue: subscription.billingFrequency),
              frequency != .none else { return "No billing cycle" }

        switch frequency {
        case .daily: return "/ day"
        case .weekly: return "/ week"
        case .monthly: return "/ month"
        case .quarterly: return "/ quarter"
        case .yearly: return "/ year"
        case .none: return "No billing cycle"
        }
    }

    private var categoryLabel: String {
        let trimmed = subscription.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? "Uncategorized" : trimmed
    }

    private var placeholderBackground: Color {
        let palette: [Color] = [.pink, .indigo, .teal, .orange]
        let index = abs(subscription.accountName.hashValue) % palette.count
        return palette[index].opacity(0.14)
    }

    private var placeholderForeground: Color {
        let palette: [Color] = [.pink, .indigo, .teal, .orange]
        let index = abs(subscription.accountName.hashValue) % palette.count
        return palette[index]
    }

    private func loadLogoImage(named logoName: String) -> UIImage? {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let logoPath = supportDir
            .appendingPathComponent("Logos", isDirectory: true)
            .appendingPathComponent("\(logoName).png")

        guard let data = try? Data(contentsOf: logoPath) else { return nil }
        return UIImage(data: data)
    }
}

#Preview("Subscription Rows") {
    List {
        Section {
            SubscriptionRow(subscription: .previewNetflix)
            SubscriptionRow(subscription: .previewSpotify)
            SubscriptionRow(subscription: .previewAdobe)
        }
    }
    .listStyle(.insetGrouped)
}

private extension Subscription {
    static let previewNetflix = Subscription(
        accountName: "Netflix",
        category: "Streaming",
        price: 15.99,
        billingDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
        billingFrequency: BillingFrequency.monthly.rawValue,
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: nil,
        logoName: nil,
        accountURL: nil,
        lastModified: Date()
    )

    static let previewSpotify = Subscription(
        accountName: "Spotify",
        category: "Music",
        price: 11.99,
        billingDate: Calendar.current.date(byAdding: .day, value: 19, to: Date()),
        billingFrequency: BillingFrequency.monthly.rawValue,
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        logoName: nil,
        accountURL: nil,
        lastModified: Date()
    )

    static let previewAdobe = Subscription(
        accountName: "Adobe Creative Cloud",
        category: "Productivity",
        price: 54.99,
        billingDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()),
        billingFrequency: BillingFrequency.monthly.rawValue,
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: nil,
        logoName: nil,
        accountURL: nil,
        lastModified: Date()
    )
}
