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
    case dateAdded = "Recently Added"
}

enum ListDisplayMode: String, CaseIterable {
    case flat = "All Subscriptions"
    case groupedByCategory = "Group by Category"
}

struct SubscriptionsTab: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subscription.accountName) private var subscriptions: [Subscription]
    @State private var showingAddSubscription = false
    @State private var subscriptionToEdit: Subscription? = nil
    @State private var subscriptionToDelete: Subscription? = nil
    @State private var showDeleteConfirmation = false
    @State private var searchText = ""
    @AppStorage("selectedSort") private var selectedSort: SortOption = .name
    @AppStorage("sortAscending") private var sortAscending: Bool = true
    @AppStorage("subscriptionsDisplayMode") private var displayMode: ListDisplayMode = .flat

    // MARK: - Computed Properties

    private var monthlyTotal: Double {
        subscriptions.reduce(0.0) { total, sub in
            let freq = BillingFrequency(rawValue: sub.billingFrequency) ?? .none
            switch freq {
            case .daily:      return total + (sub.price * 365.0 / 12.0)
            case .weekly:     return total + (sub.price * 52.0 / 12.0)
            case .monthly:    return total + sub.price
            case .quarterly:  return total + (sub.price / 3.0)
            case .yearly:     return total + (sub.price / 12.0)
            case .none:       return total
            }
        }
    }

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
        case .dateAdded:
            result.sort { sortAscending ? $0.lastModified < $1.lastModified : $0.lastModified > $1.lastModified }
        }

        return result
    }

    private var groupedSubscriptions: [(category: String, subscriptions: [Subscription])] {
        let grouped = Dictionary(grouping: displayedSubscriptions) { subscription in
            let trimmed = subscription.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return trimmed.isEmpty ? "Uncategorized" : trimmed
        }

        return grouped
            .map { (category: $0.key, subscriptions: $0.value) }
            .sorted { lhs, rhs in
                lhs.category.localizedCaseInsensitiveCompare(rhs.category) == .orderedAscending
            }
    }

    var body: some View {
        NavigationStack {
            List {
                if !subscriptions.isEmpty {
                    Section {
                        summaryStrip
                    }
                }

                if displayMode == .groupedByCategory {
                    ForEach(groupedSubscriptions, id: \.category) { group in
                        Section(group.category) {
                            ForEach(group.subscriptions) { subscription in
                                subscriptionRow(for: subscription)
                            }
                        }
                    }
                } else {
                    Section {
                        ForEach(displayedSubscriptions) { subscription in
                            subscriptionRow(for: subscription)
                        }
                    }
                }
            }
            .contentMargins(.top, 8, for: .scrollContent)
            .listSectionSpacing(.compact)
            .fullScreenCover(item: $subscriptionToEdit) { subscription in
                SubscriptionFormView(
                    subscriptionToEdit: subscription,
                    existingSubscriptions: subscriptions
                )
            }
            .alert(
                "Delete \"\(subscriptionToDelete?.accountName ?? "")\"?",
                isPresented: $showDeleteConfirmation
            ) {
                Button("Delete", role: .destructive) {
                    if let subscription = subscriptionToDelete {
                        delete(subscription)
                    }
                    subscriptionToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    subscriptionToDelete = nil
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .navigationTitle("Subscriptions")
            .navigationDestination(for: Subscription.self) { subscription in
                SubscriptionDetailView(subscription: subscription)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        if selectedSort != .name || !sortAscending || displayMode != .flat {
                            Button("Reset", systemImage: "arrow.uturn.backward") {
                                selectedSort = .name
                                sortAscending = true
                                displayMode = .flat
                            }
                        }

                        Section("View") {
                            ForEach(ListDisplayMode.allCases, id: \.self) { mode in
                                Toggle(isOn: Binding(
                                    get: { displayMode == mode },
                                    set: { _ in
                                        displayMode = mode
                                    }
                                )) {
                                    Text(mode.rawValue)
                                }
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
                                            // Recently Added defaults to newest first (descending)
                                            sortAscending = option == .dateAdded ? false : true
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
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(
                                LinearGradient(
                                    colors: [Color("BrandPink"), Color("BrandPurple")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
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
        }
        .fullScreenCover(isPresented: $showingAddSubscription) {
            SubscriptionFormView(existingSubscriptions: subscriptions.map { $0 })
        }
    }

    // MARK: - Summary Strip

    private var summaryStrip: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Snapshot")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                        .textCase(.uppercase)
                        .tracking(0.8)

                    Text(monthlyTotal, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Spacer(minLength: 12)

                Text("\(subscriptions.count) \(subscriptions.count == 1 ? "active" : "active")")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.16), in: Capsule())
            }

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("per month")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color("BrandPink"),
                            Color("BrandPurple")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.18),
                                    .clear,
                                    .black.opacity(0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private func subscriptionRow(for subscription: Subscription) -> some View {
        NavigationLink(value: subscription) {
            SubscriptionRow(subscription: subscription)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                subscriptionToDelete = subscription
                showDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                toggleReminder(for: subscription)
            } label: {
                Label(
                    subscription.remindToCancel ? "Remove Reminder" : "Remind to Cancel",
                    systemImage: subscription.remindToCancel ? "bell.slash" : "bell.badge"
                )
            }
            .tint(subscription.remindToCancel ? .orange : .teal)
        }
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                subscriptionToEdit = subscription
            }

            Button(
                subscription.remindToCancel ? "Remove Reminder" : "Remind to Cancel",
                systemImage: subscription.remindToCancel ? "bell.slash" : "bell.badge"
            ) {
                toggleReminder(for: subscription)
            }

            Divider()

            Button("Delete", systemImage: "trash", role: .destructive) {
                subscriptionToDelete = subscription
                showDeleteConfirmation = true
            }
        }
    }

    // MARK: - Actions

    private func delete(_ subscription: Subscription) {
        NotificationService.shared.removeNotification(for: subscription)
        if subscription.logoName != nil {
            LogoFetchService.shared.deleteLogo(for: subscription)
        }
        modelContext.delete(subscription)
        try? modelContext.save()
    }

    private func toggleReminder(for subscription: Subscription) {
        if subscription.remindToCancel {
            subscription.remindToCancel = false
            subscription.cancelReminderDate = nil
            NotificationService.shared.removeNotification(for: subscription)
        } else {
            subscription.remindToCancel = true
            subscription.cancelReminderDate = smartReminderDate(for: subscription)
            Task {
                await NotificationService.shared.requestPermissionIfNeeded()
                NotificationService.shared.scheduleCancelReminder(for: subscription)
            }
        }
        try? modelContext.save()
    }

    private func smartReminderDate(for subscription: Subscription) -> Date {
        let calendar = Calendar.current
        guard let billingDate = subscription.billingDate,
              let frequency = BillingFrequency(rawValue: subscription.billingFrequency),
              frequency != .none else {
            return calendar.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        }
        let nextBilling = frequency.nextBillingDate(from: billingDate)
        if let smartDate = calendar.date(byAdding: .day, value: -3, to: nextBilling),
           smartDate > Date() {
            return smartDate
        }
        return calendar.date(byAdding: .day, value: 30, to: Date()) ?? Date()
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
