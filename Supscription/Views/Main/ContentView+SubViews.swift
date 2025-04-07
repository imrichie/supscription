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
            selectedCategory: $selectedCategory,
            searchText: $searchText,
            categories: categoryCounts,
            orderedCategoryNames: orderedCategoryNames
        )
        .frame(minWidth: 200)
    }
    
    var contentListView: some View {
        ContentListView(
            subscriptions: filteredSubscriptions,
            totalSubscriptionsCount: subscriptions.count,
            selectedSubscription: $selectedSubscription,
            searchText: $searchText
        )
        .frame(minWidth: 340, idealWidth: 360, maxWidth: 400)
    }
    
    
    var detailView: some View {
        Group {
            if subscriptions.isEmpty {
                onboardingDetailView
            } else {
                populatedDetailView
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
            allSubscriptions: subscriptions
        )
        .frame(minWidth: 550)
    }
}
