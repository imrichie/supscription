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
        VStack(spacing: 4) {
            Text(subscription.accountName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if !subscription.accountDescription.isEmpty {
                Text(subscription.accountDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .windowBackgroundColor)))
    }
}
