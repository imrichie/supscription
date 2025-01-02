//
//  ContentView.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI

struct ContentView: View {

    @State private var selectedCategory: Category?
    @State private var selectedSubscription: Subscription?

    let categories = [
        Category(name: "All Subscriptions"),
        Category(name: "Streaming"),
        Category(name: "Music"),
        Category(name: "Productivity")
    ]

    let subscriptions: [String: [Subscription]] = [
        "All Subscriptions": [
            Subscription(accountName: "Netflix", description: "Streaming Services", price: 15.99),
            Subscription(accountName: "Spotify", description: "Music Subscription", price: 9.99),
            Subscription(accountName: "Adobe Creative Cloud", description: "Design Software", price: 19.99),
            Subscription(accountName: "Amazon Prime", description: "Shopping and streaming", price: 12.99),
            Subscription(accountName: "Apple Music", description: "Music Subscription", price: 9.99)
        ],
        "Streaming": [
            Subscription(accountName: "Netflix", description: "Streaming Services", price: 15.99),
            Subscription(accountName: "Amazon Prime", description: "Shopping and streaming", price: 12.99)
        ],
        "Music": [
            Subscription(accountName: "Spotify", description: "Music Subscription", price: 9.99),
            Subscription(accountName: "Apple Music", description: "Music Subscription", price: 9.99)
        ]
    ]

    var body: some View {
        NavigationSplitView {
            // Sidebar: Categories
            List(categories, selection: $selectedCategory) { category in
                Text(category.name)
                    .tag(category) // Explicitly tag each item
            }
        } content: {
            // Content: Subscriptions for the selected category
            if let selectedCategory = selectedCategory,
               let filteredSubscriptions = subscriptions[selectedCategory.name] {
                List(filteredSubscriptions, selection: $selectedSubscription) { subscription in
                    Text(subscription.accountName)
                        .tag(subscription) // Explicitly tag each item
                }
            } else {
                Text("Select a category")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        } detail: {
            // Detail: Show details for the selected subscription
            if let selectedSubscription = selectedSubscription {
                VStack {
                    Text("Selected: \(selectedSubscription.accountName)")
                        .font(.largeTitle)
                    Text(selectedSubscription.description)
                    Text(String(format: "$%.2f", selectedSubscription.price))
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()
            } else {
                Text("Select a subscription")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
}
