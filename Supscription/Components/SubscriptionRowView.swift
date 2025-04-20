//
//  SubscriptionRowView.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/31/25.
//

import SwiftUI

struct SubscriptionRowView: View {
    let subscription: Subscription
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // MARK: - Top Row (Logo, Name/Desc, Price)
            HStack(alignment: .top, spacing: 12) {
                // Logo
                if let logoName = subscription.logoName, !logoName.isEmpty {
                    if let nsImage = loadLogoImage(named: logoName) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    } else {
                        // Fallback if the image couldn't be loaded
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.gray.opacity(0.15))
                            Text(subscription.accountName.prefix(1).uppercased())
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 40, height: 40)
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.gray.opacity(0.15))
                        
                        Text(subscription.accountName.prefix(1).uppercased())
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 40, height: 40)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(subscription.accountName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    if let category = subscription.category?.trimmingCharacters(in: .whitespacesAndNewlines), !category.isEmpty {
                        Text(category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Price pill
                Text(subscription.formattedPrice)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(isSelected ? Color.gray.opacity(0.2) : Color.accentColor.opacity(0.1))
                    )
                    .foregroundColor(isSelected ? .primary : Color.accentColor)
            }
            
            // MARK: - Metadata Row (Full Width)
            HStack(spacing: 8) {
                if let billingDate = subscription.formattedBillingDate {
                    Label {
                        Text("Due \(billingDate)")
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(isSelected ? .secondary : .orange)
                    }
                }

                if let frequency = BillingFrequency(rawValue: subscription.billingFrequency), frequency != .none {
                    Label {
                        Text("Billed \(frequency.rawValue)")
                    } icon: {
                        Image(systemName: "repeat")
                            .foregroundColor(isSelected ? .secondary : .indigo)
                    }
                }

                if subscription.remindToCancel {
                    Label {
                        Text("Reminder")
                    } icon: {
                        Image(systemName: "bell")
                            .foregroundColor(isSelected ? .secondary : .teal)
                    }
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary, .tertiary)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.quaternarySystemFill))
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}
