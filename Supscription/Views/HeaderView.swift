//
//  SubscriptionHeaderView.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct HeaderView: View {
    let subscription: Subscription
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subscription.accountName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let description = subscription.accountDescription, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .windowBackgroundColor)))
    }
}
