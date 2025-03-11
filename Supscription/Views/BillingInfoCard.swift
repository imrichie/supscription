//
//  BillingInfoCard.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct BillingInfoCard: View {
    let subscription: Subscription
    
    var body: some View {
        VStack(spacing: 12) {
            DetailRow(icon: "creditcard.fill", title: "Price", value: String(format: "$%.2f", subscription.price), color: .green)
            DetailRow(icon: "calendar", title: "Billing Cycle", value: subscription.billingFrequency)
            
            if let billingDate = subscription.billingDate {
                DetailRow(icon: "calendar.badge.clock", title: "Next Billing Date", value: formatDate(billingDate), color: .orange)
            } else {
                DetailRow(icon: "exclamationmark.triangle", title: "No Billing Date Set", value: "", color: .red)
            }
            
            DetailRow(
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
