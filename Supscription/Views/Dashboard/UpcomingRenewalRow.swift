//
//  UpcomingRenewalRow.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/16/26.
//

import SwiftUI

struct UpcomingRenewalRow: View {
    let subscription: Subscription
    let onFlagToggle: () -> Void
    let onOpenWebsite: () -> Void
    let onSelectSubscription: () -> Void

    // MARK: - Urgency

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
        case ...0:
            return "Today"
        case 1...7:
            return "In \(days) days"
        default:
            if let date = subscription.nextBillingDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                return formatter.string(from: date)
            }
            return ""
        }
    }

    private var urgencyBackground: Color {
        guard let days = daysUntilBilling else { return Color.blue.opacity(0.1) }
        switch days {
        case ...0:   return Color.red.opacity(0.12)
        case 1...7:  return Color.orange.opacity(0.12)
        default:     return Color.blue.opacity(0.1)
        }
    }

    private var urgencyForeground: Color {
        guard let days = daysUntilBilling else { return .blue }
        switch days {
        case ...0:   return .red
        case 1...7:  return .orange
        default:     return .blue
        }
    }

    // MARK: - Formatting

    private var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: subscription.price)) ?? "$0.00"
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 14) {
            // Logo
            logoView

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(subscription.accountName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)

                Text(subscription.displayCategory)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            // Date badge
            if !urgencyLabel.isEmpty {
                Text(urgencyLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(urgencyForeground)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(urgencyBackground)
                    )
            }

            // Price
            Text(formattedPrice)
                .font(.subheadline.weight(.semibold))
                .frame(minWidth: 52, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 11)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectSubscription()
        }
        .contextMenu {
            Button("View Details", systemImage: "eye") {
                onSelectSubscription()
            }
            Button(
                subscription.remindToCancel ? "Remove Reminder" : "Remind to Cancel",
                systemImage: subscription.remindToCancel ? "bell.slash" : "bell.badge"
            ) {
                onFlagToggle()
            }
            if let urlString = subscription.accountURL, !urlString.isEmpty {
                Button("Open Website", systemImage: "safari") {
                    onOpenWebsite()
                }
            }
        }
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
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(0.15))
                Text(subscription.accountName.prefix(1).uppercased())
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(width: 34, height: 34)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(.separatorColor), lineWidth: 0.5)
        )
    }
}
