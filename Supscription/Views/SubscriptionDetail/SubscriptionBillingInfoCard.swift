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
        VStack(spacing: 12) {
            SubscriptionDetailRow(icon: "creditcard.fill", title: "Price", value: String(format: "$%.2f", subscription.price), color: .green)
            SubscriptionDetailRow(icon: "calendar", title: "Billing Cycle", value: subscription.billingFrequency)
            
            if let billingDate = subscription.billingDate {
                SubscriptionDetailRow(icon: "calendar.badge.clock", title: "Next Billing Date", value: formatDate(billingDate), color: .orange)
            } else {
                SubscriptionDetailRow(icon: "exclamationmark.triangle", title: "No Billing Date Set", value: "", color: .red)
            }
            
            SubscriptionDetailRow(
                icon: subscription.autoRenew ? "arrow.triangle.2.circlepath" : "xmark.circle",
                title: "Auto-Renewal",
                value: subscription.autoRenew ? "Enabled" : "Disabled",
                color: subscription.autoRenew ? .blue : .red
            )
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
