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
        if let subscriptions = subscriptions {
            List(subscriptions, selection: $selectedSubscription) { subscription in
                Text(subscription.accountName)
                    .tag(subscription)
            }
        } else {
            Text("Select a category")
                .font(.title)
                .foregroundColor(.secondary)
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
