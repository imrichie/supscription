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
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 14) {
            logoView
            
            VStack(alignment: .leading, spacing: 6) {
                Text(subscription.accountName)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    if subscription.autoRenew {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .imageScale(.small)
                            .foregroundColor(isSelected ? .white : .teal)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(isSelected ? Color.teal.opacity(0.3) : Color.teal.opacity(0.15))
                            )
                    }
                    
                    if subscription.remindToCancel {
                        Image(systemName: "bell.fill")
                            .imageScale(.small)
                            .foregroundColor(isSelected ? .white : .pink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(isSelected ? Color.pink.opacity(0.3) : Color.pink.opacity(0.15))
                            )
                            .help("Reminder set to cancel")
                    }
                }
            }
            
            Spacer()
            
            Text(subscription.formattedPrice)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white.opacity(0.25)
                                         : Color.accentColor.opacity(0.15))
                )
                .frame(minWidth: 70, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(background)
    }
    
    // MARK: - Background
    private var background: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(
                isSelected
                ? Color.accentColor.opacity(0.08)
                : Color.clear
            )
    }
    
    // MARK: - Logo View
    @ViewBuilder
    private var logoView: some View {
        if let logoName = subscription.logoName, !logoName.isEmpty,
           let nsImage = loadLogoImage(named: logoName) {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 1, y: 0.5)
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.quaternary)
                Text(subscription.accountName.prefix(1).uppercased())
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .frame(width: 44, height: 44)
        }
    }
    
    // MARK: - Helper
    private func daysUntilBilling(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 999
    }
}

// MARK: - SwiftUI Preview
#Preview("Subscription Cards") {
    VStack(spacing: 12) {
        // Regular state
        SubscriptionRowView(
            subscription: PreviewData.netflix,
            isSelected: false
        )
        
        // Selected state
        SubscriptionRowView(
            subscription: PreviewData.spotify,
            isSelected: true
        )
        
        // Expensive subscription
        SubscriptionRowView(
            subscription: PreviewData.adobe,
            isSelected: false
        )
    }
    .padding()
    .frame(width: 450)
}

// MARK: - Preview Data
private enum PreviewData {
    static let netflix = Subscription(
        accountName: "Netflix",
        category: "Streaming",
        price: 15.99,
        billingDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
        logoName: nil,
        accountURL: "netflix.com",
        lastModified: Date()
    )
    
    static let spotify = Subscription(
        accountName: "Spotify",
        category: "Music",
        price: 9.99,
        billingDate: Calendar.current.date(byAdding: .day, value: 20, to: Date()),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        logoName: nil,
        accountURL: nil,
        lastModified: Date()
    )
    
    static let adobe = Subscription(
        accountName: "Adobe Creative Cloud",
        category: "Productivity",
        price: 52.99,
        billingDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()),
        logoName: nil,
        accountURL: nil,
        lastModified: Date()
    )
}
