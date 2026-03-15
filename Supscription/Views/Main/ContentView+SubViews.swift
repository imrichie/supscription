//
//  ContentView+SubViews.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/5/25.
//

import SwiftUI

extension ContentView {
    var sidebarView: some View {
        SidebarView(
            selectedDestination: $selectedDestination,
            searchText: $searchText,
            orderedCategoryNames: orderedCategoryNames
        )
        .frame(minWidth: 220)
    }

    @ViewBuilder
    var contentColumnView: some View {
        switch selectedDestination {
        case .dashboard:
            DashboardView(subscriptions: subscriptions)

        case .subscriptions:
            HSplitView {
                subscriptionListView
                subscriptionDetailView
            }
        }
    }

    private var subscriptionListView: some View {
        ContentListView(
            subscriptions: filteredSubscriptions,
            totalSubscriptionsCount: subscriptions.count,
            selectedSubscription: $selectedSubscription,
            searchText: $searchText,
            lastSelectedID: lastSelectedID,
            hasSeenWelcomeSheet: hasSeenWelcomeSheet
        )
        .searchable(text: $searchText, placement: .automatic, prompt: "Search")
        .frame(minWidth: 300, idealWidth: 320, maxWidth: 380)
    }

    private var subscriptionDetailView: some View {
        Group {
            if subscriptions.isEmpty {
                OnboardingEmptyStateView {
                    activeSheet = .addSubscription
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SubscriptionDetailView(
                    selectedSubscription: $selectedSubscription,
                    allSubscriptions: subscriptions,
                    onDelete: {
                        lastSelectedID = nil
                    }
                )
            }
        }
        .frame(minWidth: 400, maxWidth: .infinity)
    }

    @ViewBuilder
    func sheetView(sheet: ActiveSheet) -> some View {
        switch sheet {
        case .addSubscription:
            AddSubscriptionView(
                isPresented: Binding(
                    get: { activeSheet == .addSubscription },
                    set: { if !$0 { activeSheet = nil } }
                ),
                existingSubscriptions: subscriptions,
                onAdd: { newSub in
                    selectedSubscription = newSub
                }
            )
        case .welcome:
            WelcomeSheetView {
                hasSeenWelcomeSheet = true
                activeSheet = nil
            }
        }
    }
}
