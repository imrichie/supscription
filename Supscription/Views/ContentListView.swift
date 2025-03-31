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
    @State private var isAscending: Bool = true
    
    var body: some View {
        Group {
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
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isAscending.toggle()
                }) {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isAddingSubscription = true
                }) {
                    Label("Add Subscription", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: [.command])
                
            }
        }
        .sheet(isPresented: $isAddingSubscription) {
            AddSubscriptionView(
                isPresented: $isAddingSubscription,
                existingSubscriptions: subscriptions,
                onAdd: { newSubscription in
                selectedSubscription = newSubscription
            })
        }
    }
    
    // Extracts the list structure for reuse
    private var subscriptionList: some View {
        ForEach(sortedSubscriptions, id: \.self) { subscription in
            VStack(alignment: .leading) {
                Text(subscription.accountName)
                    .font(.headline)
                if let description = subscription.accountDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 6)
        }
    }
    
    // sorting logic
    var sortedSubscriptions: [Subscription] {
        subscriptions.sorted {
            isAscending ? $0.accountName < $1.accountName : $0.accountName > $1.accountName
        }
    }
}
