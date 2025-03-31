//
//  ContentListView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI
import SwiftData

struct ContentListView: View {
    // MARK: - Parameters
    
    let subscriptions: [Subscription]
    @Binding var selectedSubscription: Subscription?
    @Binding var searchText: String
    
    // MARK: - State
    
    @State private var isAddingSubscription: Bool = false
    @State private var isAscending: Bool = true
    
    // MARK: - Computed Properties
    
    /// Returns subscriptions sorted by account name based on `isAscending` toggle
    private var sortedSubscriptions: [Subscription] {
        subscriptions.sorted {
            isAscending
            ? $0.accountName < $1.accountName
            : $0.accountName > $1.accountName
        }
    }
    
    // MARK: - View
    
    var body: some View {
        Group {
            if subscriptions.isEmpty {
                EmptySubscriptionListView()
            } else {
                List(selection: $selectedSubscription) {
                    if !searchText.isEmpty {
                        Section(header: Text("Top Hits").fontWeight(.bold)) {
                            subscriptionList
                        }
                    } else {
                        subscriptionList
                    }
                }
                .listStyle(.inset)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isAscending.toggle() }) {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
                .accessibilityLabel("Toggle sort order")
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: { isAddingSubscription = true }) {
                    Label("Add Subscription", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: [.command])
                .accessibilityLabel("Add new subscription")
            }
        }
        .sheet(isPresented: $isAddingSubscription) {
            AddSubscriptionView(
                isPresented: $isAddingSubscription,
                existingSubscriptions: subscriptions,
                onAdd: { newSubscription in
                    selectedSubscription = newSubscription
                }
            )
        }
    }
    
    // MARK: - View Builders
    
    private var subscriptionList: some View {
        ForEach(sortedSubscriptions, id: \.self) { subscription in
            SubscriptionRowView(subscription: subscription)
        }
    }
}
