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
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"

    private var categories: [String] {
        let unique = Set(subscriptions.compactMap { sub in
            let trimmed = sub.category?.trimmingCharacters(in: .whitespacesAndNewlines)
            return (trimmed?.isEmpty ?? true) ? nil : trimmed
        })
        return ["All"] + unique.sorted()
    }

    private var filteredSubscriptions: [Subscription] {
        var result = subscriptions

        if selectedCategory != "All" {
            result = result.filter { $0.category?.trimmingCharacters(in: .whitespacesAndNewlines) == selectedCategory }
        }

        if !searchText.isEmpty {
            result = result.filter { $0.accountName.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            List(filteredSubscriptions) { subscription in
                NavigationLink(value: subscription) {
                    SubscriptionRow(subscription: subscription)
                }
            }
            .navigationTitle("Subscriptions")
            .navigationDestination(for: Subscription.self) { subscription in
                SubscriptionDetailPlaceholder(subscription: subscription)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsPlaceholder()
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        ForEach(categories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                if category == selectedCategory {
                                    Label(category, systemImage: "checkmark")
                                } else {
                                    Text(category)
                                }
                            }
                        }
                    } label: {
                        Image(systemName: selectedCategory == "All"
                              ? "line.3.horizontal.decrease.circle"
                              : "line.3.horizontal.decrease.circle.fill")
                    }
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
                } else if filteredSubscriptions.isEmpty {
                    ContentUnavailableView.search(text: searchText)
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
