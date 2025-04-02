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
        VStack {
            SubscriptionDetailRow(
                icon: "bell.fill",
                title: "Reminder to Cancel",
                value: subscription.cancelReminderDate?.formattedMedium() ?? "No Date Set",
                iconColor: .orange
            )
        }
        .cardBackground()
    }
}
