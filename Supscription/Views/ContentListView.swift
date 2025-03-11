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
    @Binding var searchText: String
    
    @State private var isAddingSubscription: Bool = false
    
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
            .listStyle(.inset)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button(action: {
                        isAddingSubscription = true
                    }) {
                        Label("Add subscription", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingSubscription) {
                AddSubscriptionView(isPresented: $isAddingSubscription)
            }
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
