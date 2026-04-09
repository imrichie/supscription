//
//  SubscriptionsTab.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI
import SwiftData

enum SortOption: String, CaseIterable {
    case name = "Name"
    case price = "Price"
    case billingDate = "Billing Date"
}

struct SubscriptionsTab: View {
    @Query(sort: \Subscription.accountName) private var subscriptions: [Subscription]
    @State private var showingAddSubscription = false
    @State private var searchText = ""
    @State private var selectedCategory: String = "All"
    @State private var selectedSort: SortOption = .name

    private var hasActiveFilters: Bool {
        selectedCategory != "All" || selectedSort != .name
    }

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

        switch selectedSort {
        case .name:
            result.sort { $0.accountName.localizedCaseInsensitiveCompare($1.accountName) == .orderedAscending }
        case .price:
            result.sort { $0.price < $1.price }
        case .billingDate:
            result.sort { ($0.billingDate ?? .distantFuture) < ($1.billingDate ?? .distantFuture) }
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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Section("Sort By") {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button {
                                    selectedSort = option
                                } label: {
                                    if option == selectedSort {
                                        Label(option.rawValue, systemImage: "checkmark")
                                    } else {
                                        Text(option.rawValue)
                                    }
                                }
                            }
                        }

                        Section("Category") {
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
                        }
                    } label: {
                        Image(systemName: hasActiveFilters
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
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
        .modelContainer(previewContainer)
}
