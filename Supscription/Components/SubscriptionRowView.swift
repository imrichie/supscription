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
        .padding(.vertical, 6)
    }
}
