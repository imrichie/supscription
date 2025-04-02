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
        VStack(alignment: .leading, spacing: 4) {
            Text(subscription.accountName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let description = subscription.trimmedDescription {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .cardBackground(alignment: .leading)
    }
}
