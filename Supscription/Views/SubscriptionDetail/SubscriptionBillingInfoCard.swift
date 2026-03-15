//
//  BillingInfoCard.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct SubscriptionBillingInfoCard: View {
    let subscription: Subscription

    var body: some View {
        VStack(spacing: 0) {
            // Billing Cycle
            SubscriptionDetailRow(
                icon: "repeat",
                title: "Billing Cycle",
                value: subscription.billingFrequency,
                iconColor: .blue
            )

            Divider().padding(.leading, 46)

            // Next Billing Date
            if let nextDate = subscription.nextBillingDate {
                SubscriptionDetailRow(
                    icon: "calendar",
                    title: "Next Billing Date",
                    value: nextDate.formattedMedium(),
                    iconColor: nextDateColor
                )
            } else {
                SubscriptionDetailRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "No Billing Date Set",
                    value: "",
                    iconColor: .red
                )
            }

            Divider().padding(.leading, 46)

            // Auto-Renewal — icon square changes with state
            autoRenewalRow

            Divider().padding(.leading, 46)

            // Remind to Cancel — always shown
            remindToCancelRow
        }
        .cardBackground()
    }

    // MARK: - Auto-Renewal Row

    private var autoRenewalRow: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(subscription.autoRenew ? Color.green : Color.red)
                    .frame(width: 32, height: 32)
                Image(systemName: subscription.autoRenew ? "arrow.circlepath" : "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("Auto-Renewal")
                .font(.callout)
                .foregroundStyle(.primary)

            Spacer()

            Text(subscription.autoRenew ? "On" : "Off")
                .font(.callout.weight(.medium))
                .foregroundStyle(subscription.autoRenew ? .primary : .secondary)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Remind to Cancel Row

    private var remindToCancelRow: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(subscription.remindToCancel ? Color.orange : Color(white: 0.55))
                    .frame(width: 32, height: 32)
                Image(systemName: subscription.remindToCancel ? "bell.fill" : "bell.slash.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text("Remind to Cancel")
                .font(.callout)
                .foregroundStyle(.primary)

            Spacer()

            if subscription.remindToCancel {
                Text(subscription.cancelReminderDate?.formattedMedium() ?? "Date not set")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.primary)
            } else {
                Text("None")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: - Computed

    private var nextDateColor: Color {
        guard let date = subscription.nextBillingDate else { return .blue }
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        ).day ?? Int.max
        switch days {
        case ..<1:  return .red
        case 1...7: return .orange
        default:    return Color(red: 0.18, green: 0.65, blue: 0.56) // teal
        }
    }
}
