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
        HStack(alignment: .top, spacing: 16) {
            if let logoName = subscription.logoName, !logoName.isEmpty {
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Text(subscription.accountName.prefix(1).uppercased())
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                }
            }
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
