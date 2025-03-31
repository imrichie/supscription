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
            SubscriptionDetailRow(icon: "bell.fill", title: "Reminder to Cancel", value: subscription.cancelReminderDate != nil ? formatDate(subscription.cancelReminderDate!) : "No Date Set", color: .orange)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .windowBackgroundColor)))
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
