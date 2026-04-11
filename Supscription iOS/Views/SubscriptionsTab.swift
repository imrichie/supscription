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
    @AppStorage("selectedSort") private var selectedSort: SortOption = .name
    @AppStorage("sortAscending") private var sortAscending: Bool = true

    private var displayedSubscriptions: [Subscription] {
        var result = subscriptions

        if !searchText.isEmpty {
            result = result.filter { $0.accountName.localizedCaseInsensitiveContains(searchText) }
        }

        switch selectedSort {
        case .name:
            result.sort {
                let order = $0.accountName.localizedCaseInsensitiveCompare($1.accountName)
                return sortAscending ? order == .orderedAscending : order == .orderedDescending
            }
        case .price:
            result.sort { sortAscending ? $0.price < $1.price : $0.price > $1.price }
        case .billingDate:
            result.sort {
                let lhs = $0.billingDate ?? .distantFuture
                let rhs = $1.billingDate ?? .distantFuture
                return sortAscending ? lhs < rhs : lhs > rhs
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            List(displayedSubscriptions) { subscription in
                NavigationLink(value: subscription) {
                    SubscriptionRow(subscription: subscription)
                }
            }
            .navigationTitle("Subscriptions")
            .navigationDestination(for: Subscription.self) { subscription in
                SubscriptionDetailView(subscription: subscription)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        if selectedSort != .name || !sortAscending {
                            Button("Reset", systemImage: "arrow.uturn.backward") {
                                selectedSort = .name
                                sortAscending = true
                            }
                        }

                        Section("Sort By") {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Toggle(isOn: Binding(
                                    get: { selectedSort == option },
                                    set: { _ in
                                        if selectedSort == option {
                                            sortAscending.toggle()
                                        } else {
                                            selectedSort = option
                                            sortAscending = true
                                        }
                                    }
                                )) {
                                    Text(option.rawValue)
                                    if option == selectedSort {
                                        Text(sortAscending ? "Ascending" : "Descending")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
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
                } else if displayedSubscriptions.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .fullScreenCover(isPresented: $showingAddSubscription) {
                SubscriptionFormView(existingSubscriptions: subscriptions.map { $0 })
            }
        }
    }
}

#Preview("Subscriptions Filled") {
    SubscriptionsTab()
        .modelContainer(previewContainer)
}

#Preview("Subscriptions Empty") {
    SubscriptionsTab()
        .modelContainer(emptyPreviewContainer)
}
