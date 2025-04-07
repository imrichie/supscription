//
//  SubscriptionRowView.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/31/25.
//

import SwiftUI

struct SubscriptionRowView: View {
    let subscription: Subscription
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                // MARK: - Logo or Placeholder
                if let logoName = subscription.logoName, !logoName.isEmpty {
                    Image(logoName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 40, height: 40)
                }
                
                // MARK: - Text Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(subscription.accountName)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    if let description = subscription.trimmedDescription {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // MARK: - Price Pill
                Text(subscription.formattedPrice)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.accentColor.opacity(0.1))
                    )
                    .foregroundColor(.accentColor)
            }
            
            // MARK: - Metadata
            HStack(spacing: 8) {
                if let billingDate = subscription.formattedBillingDate {
                    Label("Due \(billingDate)", systemImage: "calendar")
                }
                
                Label("Billed \(subscription.billingFrequency.capitalized)", systemImage: "repeat")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .padding(.leading, 50)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.quaternarySystemFill))
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
