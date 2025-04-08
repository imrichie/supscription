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
    let totalSubscriptionsCount: Int
    @Binding var selectedSubscription: Subscription?
    @Binding var searchText: String
    let lastSelectedID: String?
    let hasSeenWelcomeSheet: Bool
    
    // MARK: - State
    
    @State private var isAddingSubscription: Bool = false
    @State private var isAscending: Bool = true
    
    // MARK: - Computed Properties
    
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
            if totalSubscriptionsCount == 0 {
                // Nothing in the app at all (fresh install)
                EmptyContentListView(
                    title: "Add a subscription to get started",
                    message: "You haven’t added any yet. Use the + button to begin."
                )
            } else if subscriptions.isEmpty && !searchText.isEmpty {
                // Data exists, but nothing matched the search
                EmptyContentListView(
                    title: "No subscriptions found",
                    message: "Try adjusting your search."
                )
            } else {
                // Show the actual subscription list
                ScrollViewReader { proxy in
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
                    .onAppear {
                        DispatchQueue.main.async {
                            guard
                                hasSeenWelcomeSheet,
                                !subscriptions.isEmpty,
                                searchText.isEmpty,
                                let id = lastSelectedID,
                                let uuid = UUID(uuidString: id)
                            else {
                                return
                            }
                            proxy.scrollTo(uuid, anchor: .top)
                        }
                    }
                }
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
            SubscriptionRowView(
                subscription: subscription,
                isSelected: selectedSubscription?.id == subscription.id
            ).id(subscription.id)
        }
    }
}
