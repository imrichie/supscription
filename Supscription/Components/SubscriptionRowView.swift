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
        HStack(alignment: .center, spacing: 8) {
            if let logoName = subscription.logoName, !logoName.isEmpty {
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 40, height: 40)
            }
            VStack(alignment: .leading) {
                Text(subscription.accountName)
                    .font(.headline)
                
                if let description = subscription.accountDescription,
                   !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
