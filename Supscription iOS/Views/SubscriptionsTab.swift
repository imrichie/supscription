//
//  SubscriptionsTab.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI
import SwiftData

struct SubscriptionsTab: View {
    @Query(sort: \Subscription.accountName) private var subscriptions: [Subscription]
    @State private var showingAddSubscription = false

    var body: some View {
        NavigationStack {
            List(subscriptions) { subscription in
                NavigationLink(value: subscription) {
                    SubscriptionRow(subscription: subscription)
                }
            }
            .navigationTitle("Subscriptions")
            .navigationDestination(for: Subscription.self) { subscription in
                SubscriptionDetailPlaceholder(subscription: subscription)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsPlaceholder()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSubscription = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if subscriptions.isEmpty {
                    ContentUnavailableView {
                        Label("No Subscriptions", systemImage: "creditcard")
                    } description: {
                        Text("Track your recurring subscriptions in one place.")
                    } actions: {
                        Button("Add Subscription") {
                            showingAddSubscription = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .sheet(isPresented: $showingAddSubscription) {
                AddSubscriptionPlaceholder()
            }
        }
    }
}

#Preview {
    SubscriptionsTab()
        .modelContainer(for: Subscription.self, inMemory: true)
}
