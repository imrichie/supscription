//
//  SubscriptionHeaderView.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct SubscriptionHeaderView: View {
    let subscription: Subscription

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            logoView

            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.accountName)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(subscription.formattedPrice)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primary)

                    if !frequencyLabel.isEmpty {
                        Text(frequencyLabel)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }

                statusBadge
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }

    // MARK: - Logo

    @ViewBuilder
    private var logoView: some View {
        ZStack {
            if let logoName = subscription.logoName, !logoName.isEmpty,
               let nsImage = loadLogoImage(named: logoName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.secondary.opacity(0.1))
                Text(subscription.accountName.prefix(1).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 80, height: 80)
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.gray.opacity(0.12), lineWidth: 0.5)
        )
    }

    // MARK: - Status Badge

    @ViewBuilder
    private var statusBadge: some View {
        if let text = statusText {
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.12), in: Capsule())
        }
    }

    // MARK: - Computed

    private var frequencyLabel: String {
        guard let freq = BillingFrequency(rawValue: subscription.billingFrequency),
              freq != .none else { return "" }
        switch freq {
        case .daily:     return "/ day"
        case .weekly:    return "/ week"
        case .monthly:   return "/ month"
        case .quarterly: return "/ quarter"
        case .yearly:    return "/ year"
        case .none:      return ""
        }
    }

    private var daysUntilBilling: Int? {
        guard let date = subscription.nextBillingDate else { return nil }
        return Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        ).day
    }

    private var statusText: String? {
        guard let days = daysUntilBilling else { return nil }
        switch days {
        case ..<0:  return "Overdue"
        case 0:     return "Due today"
        case 1:     return "Due tomorrow"
        default:    return "Due in \(days) days"
        }
    }

    private var statusColor: Color {
        guard let days = daysUntilBilling else { return .secondary }
        switch days {
        case ..<1:  return .red
        case 1...7: return .orange
        default:    return .teal
        }
    }
}
