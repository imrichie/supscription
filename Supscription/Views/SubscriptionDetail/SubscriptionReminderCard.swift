//
//  ReminderCard.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct SubscriptionReminderCard: View {
    let subscription: Subscription

    var body: some View {
        VStack(spacing: 0) {
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
                    Text("Not enabled")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 10)
        }
        .cardBackground()
    }
}
