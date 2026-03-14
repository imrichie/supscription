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
            categories: categoryCounts,
            orderedCategoryNames: orderedCategoryNames
        )
        .frame(minWidth: 220)
    }

    @ViewBuilder
    var contentColumnView: some View {
        switch selectedDestination {
        case .dashboard:
            DashboardView(subscriptions: subscriptions)
                .frame(minWidth: 700)
        case .subscriptions:
            ContentListView(
                subscriptions: filteredSubscriptions,
                totalSubscriptionsCount: subscriptions.count,
                selectedSubscription: $selectedSubscription,
                searchText: $searchText,
                lastSelectedID: lastSelectedID,
                hasSeenWelcomeSheet: hasSeenWelcomeSheet
            )
            .frame(minWidth: 360)
        }
    }

    @ViewBuilder
    var detailColumnView: some View {
        switch selectedDestination {
        case .dashboard:
            EmptyView()
        case .subscriptions:
            Group {
                if subscriptions.isEmpty {
                    onboardingDetailView
                } else {
                    populatedDetailView
                }
            }
        }
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

    private var onboardingDetailView: some View {
        OnboardingEmptyStateView {
            activeSheet = .addSubscription
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var populatedDetailView: some View {
        SubscriptionDetailView(
            selectedSubscription: $selectedSubscription,
            allSubscriptions: subscriptions,
            onDelete: {
                lastSelectedID = nil
            }
        )
        .frame(minWidth: 550)
    }
}
