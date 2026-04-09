//
//  SubscriptionDetailPlaceholder.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI

struct SubscriptionDetailPlaceholder: View {
    let subscription: Subscription

    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Name", value: subscription.accountName)
                LabeledContent("Price") {
                    Text(subscription.price, format: .currency(code: "USD"))
                }
                LabeledContent("Frequency", value: subscription.billingFrequency)
                if let category = subscription.category {
                    LabeledContent("Category", value: category)
                }
            }

            if let url = subscription.accountURL, !url.isEmpty {
                Section("Account") {
                    LabeledContent("Website", value: url)
                }
            }

            Section("Billing") {
                LabeledContent("Auto-Renew", value: subscription.autoRenew ? "Yes" : "No")
                if let billingDate = subscription.billingDate {
                    LabeledContent("Billing Date") {
                        Text(billingDate, style: .date)
                    }
                }
                if let nextDate = subscription.nextBillingDate {
                    LabeledContent("Next Billing") {
                        Text(nextDate, style: .date)
                    }
                }
            }
        }
        .navigationTitle(subscription.accountName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
