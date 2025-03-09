//
//  ContentListView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI
import SwiftData

struct ContentListView: View {
    let subscriptions: [Subscription]
    @Binding var selectedSubscription: Subscription?
    @Binding var searchText: String // Tracks whether search is active
    
    var body: some View {
        if subscriptions.isEmpty {
            EmptyContentListView()
        } else {
            List(selection: $selectedSubscription) {
                // Show "Search Results" header when search is active
                if !searchText.isEmpty {
                    Section(header: Text("Top Hits")
                        .fontWeight(.bold)) {
                        subscriptionList
                    }
                } else {
                    subscriptionList
                }
            }
            .listStyle(.inset) // Matches macOS standard UI
        }
    }

    // Extracts the list structure for reuse
    private var subscriptionList: some View {
        ForEach(subscriptions, id: \.self) { subscription in
            VStack(alignment: .leading) {
                Text(subscription.accountName)
                    .font(.headline)
                Text(subscription.accountDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    let previewSubscriptions = [
        Subscription(
            accountName: "Netflix",
            accountDescription: "Streaming Services",
            category: "Streaming",
            price: 15.99,
            billingDate: Date(),
            billingFrequency: "Monthly",
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil
        ),
        Subscription(
            accountName: "Spotify",
            accountDescription: "Music Subscription",
            category: "Music",
            price: 9.99,
            billingDate: Date(),
            billingFrequency: "Monthly",
            autoRenew: true,
            remindToCancel: true,
            cancelReminderDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())
        )
    ]

    ContentListView(
        subscriptions: previewSubscriptions,
        selectedSubscription: .constant(nil),
        searchText: .constant("Node")
    )
}

