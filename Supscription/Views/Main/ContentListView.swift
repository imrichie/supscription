//
//  ContentListView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI
import SwiftData

struct ContentListView: View {
    @Environment(SubscriptionSelectionStore.self) var selectionStore
    
    // MARK: - Parameters
    let subscriptions: [Subscription]
    let totalSubscriptionsCount: Int
    @Binding var selectedSubscription: Subscription?
    @Binding var searchText: String
    let lastSelectedID: String?
    let hasSeenWelcomeSheet: Bool
    
    // MARK: - State
    @State private var isAddingSubscription: Bool = false
    @AppStorage("sortOption") private var sortOptionRawValue: String = SortOption.name.rawValue
    @AppStorage("isAscending") private var isAscending: Bool = true
    
    // Helper binding for sortOption
    private var sortOptionPickerBinding: Binding<SortOption> {
        Binding<SortOption>(
            get: { SortOption(rawValue: sortOptionRawValue) ?? .name },
            set: { sortOptionRawValue = $0.rawValue }
        )
    }
    
    // MARK: - Computed Properties
    private var sortMenu: some View {
        Menu {
            // Sort Options
            Picker(selection: sortOptionPickerBinding, label: EmptyView()) {
                Text("Name").tag(SortOption.name)
                Text("Price").tag(SortOption.price)
                Text("Billing Date").tag(SortOption.billingDate)
                Text("Category").tag(SortOption.category)
            }
            .pickerStyle(.inline)
            
            Divider()
            
            // Sort Direction
            Picker(selection: $isAscending, label: EmptyView()) {
                Text("Ascending").tag(true)
                Text("Descending").tag(false)
            }
            .pickerStyle(.inline)
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }
    
    private var addSubscriptionButton: some View {
        Button(action: { isAddingSubscription = true }) {
            Label("Add Subscription", systemImage: "plus")
        }
        .keyboardShortcut("n", modifiers: [.command])
        .accessibilityLabel("Add new subscription")
    }
    
    private var sortedSubscriptions: [Subscription] {
        let sortOption = SortOption(rawValue: sortOptionRawValue) ?? .name
        
        return subscriptions.sorted { lhs, rhs in
            switch sortOption {
            case .name:
                return isAscending
                ? lhs.accountName.localizedCaseInsensitiveCompare(rhs.accountName) == .orderedAscending
                : lhs.accountName.localizedCaseInsensitiveCompare(rhs.accountName) == .orderedDescending
                
            case .price:
                return isAscending ? lhs.price < rhs.price : lhs.price > rhs.price
                
            case .billingDate:
                let lhsDate = lhs.billingDate ?? .distantFuture
                let rhsDate = rhs.billingDate ?? .distantFuture
                return isAscending ? lhsDate < rhsDate : lhsDate > rhsDate
                
            case .category:
                let lhsCategory = lhs.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let rhsCategory = rhs.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return isAscending
                ? lhsCategory.localizedCaseInsensitiveCompare(rhsCategory) == .orderedAscending
                : lhsCategory.localizedCaseInsensitiveCompare(rhsCategory) == .orderedDescending
            }
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
                sortMenu
            }
            ToolbarItem(placement: .primaryAction) {
                addSubscriptionButton
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
        .onReceive(NotificationCenter.default.publisher(for: .newSubscription)) { _ in
            isAddingSubscription = true
        }
        .onChange(of: selectedSubscription) { _, newValue in
            selectionStore.selected = newValue
        }
    }
    
    // MARK: - View Builders
    private var subscriptionList: some View {
        let grouped = sortedSubscriptions.groupedByBillingSection()

        return Group {
            if sortOptionRawValue == SortOption.billingDate.rawValue {
                ForEach(BillingSection.allCases, id: \.self) { section in
                    if let subs = grouped[section], !subs.isEmpty {
                        Section(header:
                                    Text(section.rawValue)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                            .textCase(nil)
                                
                        ) {
                            ForEach(subs, id: \.self) { subscription in
                                SubscriptionRowView(
                                    subscription: subscription,
                                    isSelected: selectedSubscription?.id == subscription.id
                                )
                                .id(subscription.id)
                            }
                        }
                    }
                }
            } else {
                ForEach(sortedSubscriptions, id: \.self) { subscription in
                    SubscriptionRowView(
                        subscription: subscription,
                        isSelected: selectedSubscription?.id == subscription.id
                    )
                    .id(subscription.id)
                }
            }
        }
    }
    
    // MARK: - Advanced Filtering Enum    
    enum SortOption: String, CaseIterable {
        case name
        case price
        case billingDate
        case category
    }
}
