//
//  BillingInfoCard.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct SubscriptionBillingInfoCard: View {
    // MARK: - Parameters
    
    let subscription: Subscription
    
    // MARK: - View
    
    var body: some View {
        VStack(spacing: 12) {
            SubscriptionDetailRow(
                icon: "creditcard.fill",
                title: "Price",
                value: String(format: "$%.2f", subscription.price),
                iconColor: .green
            )
            
            SubscriptionDetailRow(
                icon: "calendar",
                title: "Billing Cycle",
                value: subscription.billingFrequency
            )
            
            if let nextDate = subscription.nextBillingDate {
                SubscriptionDetailRow(
                    icon: "calendar.badge.clock",
                    title: "Next Billing Date",
                    value: nextDate.formattedMedium(),
                    iconColor: .orange
                )
            } else {
                SubscriptionDetailRow(
                    icon: "exclamationmark.triangle",
                    title: "No Billing Date Set",
                    value: "",
                    iconColor: .red
                )
            }
            
            SubscriptionDetailRow(
                icon: "arrow.triangle.2.circlepath",
                title: "Auto-Renewal",
                value: subscription.autoRenew ? "Enabled" : "Not Enabled",
                iconColor: .blue
            )
        }
        .cardBackground()
    }
}
