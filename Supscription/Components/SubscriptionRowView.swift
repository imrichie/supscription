//
//  SubscriptionRowView.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/31/25.
//

import SwiftUI

struct SubscriptionRowView: View {
    let subscription: Subscription
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            logoView

            // MARK: - Text Content
            VStack(alignment: .leading, spacing: 3) {
                Text(subscription.accountName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(subscription.displayCategory)
                        .font(.caption)
                        .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color(nsColor: .tertiaryLabelColor))

                    if dueDateText != nil {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(isSelected ? Color.white.opacity(0.5) : Color(nsColor: .quaternaryLabelColor))

                        Text(dueDateText!)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(isSelected ? Color.white.opacity(0.85) : dueDateColor)
                    }

                    if subscription.remindToCancel {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color(nsColor: .secondaryLabelColor))
                    }
                }
            }

            Spacer()

            // MARK: - Price
            VStack(alignment: .trailing, spacing: 2) {
                Text(subscription.formattedPrice)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? .white : .primary)

                Text(frequencyLabel)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.white.opacity(0.6) : Color(nsColor: .tertiaryLabelColor))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(selectionBackground)
    }

    // MARK: - Selection Background
    private var selectionBackground: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(isSelected ? Color.accentColor : Color.clear)
    }

    // MARK: - Logo View
    @ViewBuilder
    private var logoView: some View {
        ZStack {
            if let logoName = subscription.logoName, !logoName.isEmpty,
               let nsImage = loadLogoImage(named: logoName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.accentColor.opacity(0.12))
                Text(subscription.accountName.prefix(1).uppercased())
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.accentColor.opacity(0.8))
            }
        }
        .frame(width: 48, height: 48)
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
    }

    // MARK: - Due Date
    private var daysUntilBilling: Int? {
        guard let date = subscription.nextBillingDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).day
    }

    private var dueDateText: String? {
        guard let days = daysUntilBilling else { return nil }
        switch days {
        case ..<0:   return "Overdue"
        case 0:      return "Due today"
        case 1:      return "Due tomorrow"
        default:     return "Due in \(days) days"
        }
    }

    private var dueDateColor: Color {
        guard let days = daysUntilBilling else { return .secondary }
        switch days {
        case ..<1:   return .red
        case 1...7:  return .orange
        default:     return .secondary
        }
    }

    // MARK: - Frequency Label
    private var frequencyLabel: String {
        guard let frequency = BillingFrequency(rawValue: subscription.billingFrequency),
              frequency != .none else { return "" }
        switch frequency {
        case .daily:     return "/ day"
        case .weekly:    return "/ week"
        case .monthly:   return "/ mo"
        case .quarterly: return "/ qtr"
        case .yearly:    return "/ yr"
        case .none:      return ""
        }
    }
}

// MARK: - Preview
#Preview("Subscription Rows") {
    VStack(spacing: 2) {
        SubscriptionRowView(subscription: PreviewData.netflix, isSelected: false)
        SubscriptionRowView(subscription: PreviewData.spotify, isSelected: true)
        SubscriptionRowView(subscription: PreviewData.adobe, isSelected: false)
        SubscriptionRowView(subscription: PreviewData.overdue, isSelected: false)
    }
    .padding(12)
    .frame(width: 380)
}

private enum PreviewData {
    static let netflix = Subscription(
        accountName: "Netflix",
        category: "Streaming",
        price: 15.99,
        billingDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: nil,
        logoName: nil,
        accountURL: nil,
        lastModified: Date()
    )
    static let spotify = Subscription(
        accountName: "Spotify",
        category: "Music",
        price: 9.99,
        billingDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        logoName: nil,
        accountURL: nil,
        lastModified: Date()
    )
    static let adobe = Subscription(
        accountName: "Adobe Creative Cloud",
        category: "Productivity",
        price: 54.99,
        billingDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        logoName: nil,
        accountURL: nil,
        lastModified: Date()
    )
    static let overdue = Subscription(
        accountName: "iCloud+",
        category: "Storage",
        price: 2.99,
        billingDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: nil,
        logoName: nil,
        accountURL: nil,
        lastModified: Date()
    )
}
