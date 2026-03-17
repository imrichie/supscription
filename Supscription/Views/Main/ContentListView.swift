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

    private var sortOptionPickerBinding: Binding<SortOption> {
        Binding<SortOption>(
            get: { SortOption(rawValue: sortOptionRawValue) ?? .name },
            set: { sortOptionRawValue = $0.rawValue }
        )
    }

    // MARK: - Toolbar Items
    private var sortMenu: some View {
        Menu {
            Picker(selection: sortOptionPickerBinding, label: EmptyView()) {
                Text("Name").tag(SortOption.name)
                Text("Price").tag(SortOption.price)
                Text("Billing Date").tag(SortOption.billingDate)
                Text("Category").tag(SortOption.category)
            }
            .pickerStyle(.inline)

            Divider()

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

    // MARK: - Sorted Subscriptions
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
                let lhsCat = lhs.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let rhsCat = rhs.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                return isAscending
                    ? lhsCat.localizedCaseInsensitiveCompare(rhsCat) == .orderedAscending
                    : lhsCat.localizedCaseInsensitiveCompare(rhsCat) == .orderedDescending
            }
        }
    }

    // MARK: - Body
    var body: some View {
        Group {
            if totalSubscriptionsCount == 0 {
                Color.clear
            } else if subscriptions.isEmpty && !searchText.isEmpty {
                EmptyContentListView(
                    title: "No subscriptions found",
                    message: "Try adjusting your search."
                )
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            if !searchText.isEmpty {
                                sectionHeader("Top Hits")
                            }
                            subscriptionList
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            guard
                                hasSeenWelcomeSheet,
                                !subscriptions.isEmpty,
                                searchText.isEmpty,
                                let id = lastSelectedID,
                                let uuid = UUID(uuidString: id)
                            else { return }
                            proxy.scrollTo(uuid, anchor: .top)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) { sortMenu }
            ToolbarItem(placement: .primaryAction) { addSubscriptionButton }
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

    // MARK: - Subscription List
    @ViewBuilder
    private var subscriptionList: some View {
        if sortOptionRawValue == SortOption.billingDate.rawValue {
            let grouped = sortedSubscriptions.groupedByBillingSection()
            ForEach(BillingSection.allCases, id: \.self) { section in
                if let subs = grouped[section], !subs.isEmpty {
                    Section {
                        ForEach(subs, id: \.self) { subscription in
                            row(for: subscription)
                        }
                    } header: {
                        sectionHeader(section.rawValue)
                    }
                }
            }
        } else {
            ForEach(sortedSubscriptions, id: \.self) { subscription in
                row(for: subscription)
            }
        }
    }

    // MARK: - Row
    private func row(for subscription: Subscription) -> some View {
        SubscriptionRowView(
            subscription: subscription,
            isSelected: selectedSubscription?.id == subscription.id
        )
        .id(subscription.id)
        .padding(.vertical, 3)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedSubscription = subscription
        }
    }

    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.callout.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 8)
            .padding(.bottom, 2)
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .windowBackgroundColor))
            .textCase(nil)
    }

    // MARK: - Sort Option
    enum SortOption: String, CaseIterable {
        case name
        case price
        case billingDate
        case category
    }
}
