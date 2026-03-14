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

    // MARK: - Deterministic Avatar Color
    private static let palette: [Color] = [
        .red, .orange, .green, .teal, .blue, .indigo, .purple, .pink, .brown, .cyan
    ]

    private var avatarColor: Color {
        let hash = subscription.accountName.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        return Self.palette[abs(hash) % Self.palette.count]
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            logoView

            // MARK: - Text Content
            VStack(alignment: .leading, spacing: 3) {
                Text(subscription.accountName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(subscription.displayCategory)
                        .font(.caption)
                        .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color(nsColor: .tertiaryLabelColor))

                    if let dateText = dueDateText {
                        Text("·")
                            .font(.caption)
                            .foregroundStyle(isSelected ? Color.white.opacity(0.4) : Color(nsColor: .quaternaryLabelColor))

                        Text(dateText)
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
            VStack(alignment: .trailing, spacing: 1) {
                Text(subscription.formattedPrice)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? Color.white : Color.primary)

                Text(frequencyLabel)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? Color.white.opacity(0.6) : Color(nsColor: .tertiaryLabelColor))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(cardBackground)
    }

    // MARK: - Card Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(isSelected ? Color.accentColor : Color(nsColor: .controlBackgroundColor))
            .shadow(
                color: isSelected ? Color.accentColor.opacity(0.35) : Color.black.opacity(0.07),
                radius: isSelected ? 8 : 2,
                x: 0,
                y: isSelected ? 4 : 1
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.1), lineWidth: 0.5)
            )
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
                    .fill(avatarColor.opacity(isSelected ? 0.3 : 0.12))
                Text(subscription.accountName.prefix(1).uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? Color.white.opacity(0.9) : avatarColor)
            }
        }
        .frame(width: 48, height: 48)
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isSelected ? Color.clear : Color.gray.opacity(0.12), lineWidth: 0.5)
        )
    }

    // MARK: - Due Date
    private var daysUntilBilling: Int? {
        guard let date = subscription.nextBillingDate else { return nil }
        return Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        ).day
    }

    private var dueDateText: String? {
        guard let days = daysUntilBilling else { return nil }
        switch days {
        case ..<0:  return "Overdue"
        case 0:     return "Due today"
        case 1:     return "Due tomorrow"
        default:    return "Due in \(days) days"
        }
    }

    private var dueDateColor: Color {
        guard let days = daysUntilBilling else { return .secondary }
        switch days {
        case ..<1:  return .red
        case 1...7: return .orange
        default:    return Color(nsColor: .secondaryLabelColor)
        }
    }

    // MARK: - Frequency Label
    private var frequencyLabel: String {
        guard let frequency = BillingFrequency(rawValue: subscription.billingFrequency),
              frequency != .none else { return "" }
        switch frequency {
        case .daily:     return "/ day"
        case .weekly:    return "/ wk"
        case .monthly:   return "/ mo"
        case .quarterly: return "/ qtr"
        case .yearly:    return "/ yr"
        case .none:      return ""
        }
    }
}

// MARK: - Preview
#Preview("Subscription Rows") {
    VStack(spacing: 6) {
        SubscriptionRowView(subscription: PreviewData.netflix, isSelected: false)
        SubscriptionRowView(subscription: PreviewData.spotify, isSelected: true)
        SubscriptionRowView(subscription: PreviewData.adobe, isSelected: false)
        SubscriptionRowView(subscription: PreviewData.icloud, isSelected: false)
    }
    .padding(12)
    .frame(width: 380)
    .background(Color(nsColor: .windowBackgroundColor))
}

private enum PreviewData {
    static let netflix = Subscription(
        accountName: "Netflix", category: "Streaming", price: 15.99,
        billingDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
        billingFrequency: "Monthly", autoRenew: true, remindToCancel: true,
        cancelReminderDate: nil, logoName: nil, accountURL: nil, lastModified: Date()
    )
    static let spotify = Subscription(
        accountName: "Spotify", category: "Music", price: 9.99,
        billingDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()),
        billingFrequency: "Monthly", autoRenew: true, remindToCancel: false,
        cancelReminderDate: nil, logoName: nil, accountURL: nil, lastModified: Date()
    )
    static let adobe = Subscription(
        accountName: "Adobe Creative Cloud", category: "Productivity", price: 54.99,
        billingDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
        billingFrequency: "Monthly", autoRenew: true, remindToCancel: false,
        cancelReminderDate: nil, logoName: nil, accountURL: nil, lastModified: Date()
    )
    static let icloud = Subscription(
        accountName: "iCloud+", category: "Storage", price: 2.99,
        billingDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()),
        billingFrequency: "Monthly", autoRenew: true, remindToCancel: true,
        cancelReminderDate: nil, logoName: nil, accountURL: nil, lastModified: Date()
    )
}
