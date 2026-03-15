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
                icon: "arrow.trianglehead.clockwise",
                title: "Billing Cycle",
                value: subscription.billingFrequency
            )

            Divider().padding(.leading, 36)

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
                    icon: "exclamationmark.triangle",
                    title: "No Billing Date Set",
                    value: "",
                    iconColor: .red
                )
            }

            Divider().padding(.leading, 36)

            // Auto-Renewal — binary state gets a dot indicator
            autoRenewalRow

            Divider().padding(.leading, 36)

            // Remind to Cancel — always shown
            remindToCancelRow
        }
        .cardBackground()
    }

    // MARK: - Auto-Renewal Row

    private var autoRenewalRow: some View {
        HStack {
            Label {
                Text("Auto-Renewal")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }

            Spacer()

            HStack(spacing: 5) {
                Circle()
                    .fill(subscription.autoRenew ? Color.green : Color.secondary.opacity(0.5))
                    .frame(width: 7, height: 7)
                Text(subscription.autoRenew ? "On" : "Off")
                    .font(.subheadline)
                    .foregroundStyle(subscription.autoRenew ? .primary : .secondary)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Remind to Cancel Row

    private var remindToCancelRow: some View {
        HStack {
            Label {
                Text("Remind to Cancel")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: "bell.fill")
                    .foregroundStyle(subscription.remindToCancel ? Color.orange : Color.secondary)
                    .frame(width: 24, height: 24)
            }

            Spacer()

            if subscription.remindToCancel {
                Text(subscription.cancelReminderDate?.formattedMedium() ?? "Date not set")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            } else {
                Text("None")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Computed

    private var nextDateColor: Color {
        guard let date = subscription.nextBillingDate else { return .secondary }
        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        ).day ?? Int.max
        switch days {
        case ..<1:  return .red
        case 1...7: return .orange
        default:    return .secondary
        }
    }
}
