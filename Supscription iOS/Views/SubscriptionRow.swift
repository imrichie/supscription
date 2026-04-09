//
//  SubscriptionRow.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI

struct SubscriptionRow: View {
    let subscription: Subscription

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.accountName)
                    .font(.headline)
                if let category = subscription.category,
                   !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(subscription.price, format: .currency(code: "USD"))
                    .font(.subheadline.weight(.medium))
                Text(subscription.billingFrequency)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
