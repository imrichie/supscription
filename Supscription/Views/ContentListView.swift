//
//  ContentListView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI

struct ContentListView: View {
    @Binding var selectedSubscription: Subscription?
    let subscriptions: [Subscription]?
    
    var body: some View {
        if let subscriptions = subscriptions, !subscriptions.isEmpty {
            List(subscriptions, selection: $selectedSubscription) { subscription in
                VStack(alignment: .leading) {
                    Text(subscription.accountName)
                        .font(.headline)
                    Text(subscription.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
                .tag(subscription)
            }
        } else {
            VStack {
                Spacer() // Push content to the center

                Image(systemName: "tray")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray.opacity(0.6)) // Subtle gray for the icon
                    .padding(.bottom, 12)

                Text("No Subscriptions Found")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.bottom, 6)

                Text("Try selecting a different category or clear your filters.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    @Previewable @State var selectedSubscription: Subscription? = nil
    
    // Dummy data for the preview
    let sampleSubscriptions = [
        Subscription(accountName: "Netflix", description: "Streaming Services", price: 15.99),
        Subscription(accountName: "Spotify", description: "Music Subscription", price: 9.99)
    ]
    
    return ContentListView(
        selectedSubscription: $selectedSubscription,
        subscriptions: sampleSubscriptions
    )
}
