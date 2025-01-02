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
            ContentUnavailableView("Select a Category", systemImage: "doc.text.image.fill")
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
