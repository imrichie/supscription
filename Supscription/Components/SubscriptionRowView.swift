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

    // MARK: - Urgency Color (drives avatar)
    private var urgencyColor: Color {
        guard let days = daysUntilBilling else { return Color(nsColor: .systemGray) }
        switch days {
        case ..<1:  return .red
        case 1...7: return .orange
        default:    return .teal
        }
    }

    // MARK: - Body
    var body: some View {
        HStack(spacing: 12) {
            logoView

            VStack(alignment: .leading, spacing: 3) {
                Text(subscription.accountName)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    // Category chip (Option B)
                    Text(subscription.displayCategory)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color.secondary.opacity(0.1))
                        )

                    // Due date with icon (Option A)
                    if let dateText = dueDateText {
                        HStack(spacing: 3) {
                            Image(systemName: "calendar")
                                .font(.system(size: 9, weight: .medium))
                            Text(dateText)
                                .font(.caption.weight(.medium))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .foregroundStyle(dueDateColor)
                    }

                    // Reminder bell
                    if subscription.remindToCancel {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    }
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 1) {
                Text(subscription.formattedPrice)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.primary)

                Text(frequencyLabel)
                    .font(.caption2)
                    .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(cardBackground)
    }

    // MARK: - Card Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(isSelected ? Color.accentColor.opacity(0.08) : Color(nsColor: .controlBackgroundColor))
            .shadow(color: .black.opacity(0.07), radius: 2, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(
                        isSelected ? Color.accentColor.opacity(0.7) : Color.gray.opacity(0.1),
                        lineWidth: isSelected ? 1.5 : 0.5
                    )
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
                    .fill(urgencyColor.opacity(0.12))
                Text(subscription.accountName.prefix(1).uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(urgencyColor)
            }
        }
        .frame(width: 48, height: 48)
        .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
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
        guard let days = daysUntilBilling else { return Color(nsColor: .secondaryLabelColor) }
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
