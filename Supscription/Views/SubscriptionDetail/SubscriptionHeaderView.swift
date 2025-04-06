//
//  SubscriptionHeaderView.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct SubscriptionHeaderView: View {
    let subscription: Subscription
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 48, height: 48)
            VStack(alignment: .leading) {
                Text(subscription.accountName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let description = subscription.trimmedDescription {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .cardBackground(alignment: .leading)
    }
}
