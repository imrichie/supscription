//
//  UpcomingRenewalRow.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/10/26.
//

import SwiftUI

struct UpcomingRenewalRow: View {
    let subscription: Subscription

    var body: some View {
        HStack(spacing: 12) {
            subscriptionIcon

            VStack(alignment: .leading, spacing: 5) {
                Text(subscription.accountName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                if let category = subscription.category,
                   !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 7) {
                Text(subscription.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.subheadline.weight(.semibold))

                urgencyBadge
            }
        }
        .padding(.vertical, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(subscription.accountName)
        .accessibilityValue(accessibilitySummary)
    }

    // MARK: - Logo / Icon

    @ViewBuilder
    private var subscriptionIcon: some View {
        if let logoName = subscription.logoName, !logoName.isEmpty,
           let uiImage = loadLogoImage(named: logoName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 38, height: 38)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(urgencyColor.opacity(0.12))
                    .frame(width: 38, height: 38)
                Text(subscription.accountName.prefix(1).uppercased())
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(urgencyColor)
            }
        }
    }

    // MARK: - Urgency Badge

    private var urgencyBadge: some View {
        Text(urgencyLabel)
            .font(.caption2.weight(.medium))
            .foregroundStyle(urgencyColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(urgencyColor.opacity(0.12))
            )
    }

    // MARK: - Urgency Helpers

    private var daysUntilBilling: Int? {
        guard let date = subscription.nextBillingDate else { return nil }
        return Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        ).day
    }

    private var urgencyLabel: String {
        guard let days = daysUntilBilling else { return "" }
        switch days {
        case ...0:    return "Today"
        case 1:       return "Tomorrow"
        case 2...7:   return "In \(days) days"
        default:
            return subscription.nextBillingDate?.formattedShortFriendly() ?? ""
        }
    }

    private var urgencyColor: Color {
        guard let days = daysUntilBilling else { return .blue }
        switch days {
        case ...0:    return .red
        case 1...7:   return .orange
        default:      return .blue
        }
    }

    private var accessibilitySummary: String {
        let category = {
            let trimmed = subscription.category?.trimmingCharacters(in: .whitespacesAndNewlines)
            return (trimmed?.isEmpty ?? true) ? "Uncategorized" : trimmed!
        }()
        let price = subscription.price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))

        if urgencyLabel.isEmpty {
            return "\(category). \(price)."
        }

        return "\(category). \(price). Due \(urgencyLabel.lowercased())."
    }

    // MARK: - Image Loading

    private func loadLogoImage(named logoName: String) -> UIImage? {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let logoPath = supportDir
            .appendingPathComponent("Logos", isDirectory: true)
            .appendingPathComponent("\(logoName).png")

        guard let data = try? Data(contentsOf: logoPath) else { return nil }
        return UIImage(data: data)
    }
}

#Preview("Upcoming Renewal Row") {
    UpcomingRenewalRow(subscription: sampleSubscriptions[0])
        .padding()
        .background(Color(.systemBackground))
}
