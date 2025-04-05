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
            categories: categoryCounts
        )
        .frame(minWidth: 200)
    }

    var contentListView: some View {
        Group {
            if subscriptions.isEmpty {
                Text("Add a subscription to get started")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
                    .disabled(true)
            } else {
                ContentListView(
                    subscriptions: filteredSubscriptions,
                    selectedSubscription: $selectedSubscription,
                    searchText: $searchText
                )
                .frame(minWidth: 300)
            }
        }
    }

    var detailView: some View {
        Group {
            if subscriptions.isEmpty {
                OnboardingEmptyStateView {
                    activeSheet = .addSubscription
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SubscriptionDetailView(
                    selectedSubscription: $selectedSubscription,
                    allSubscriptions: subscriptions
                )
                .frame(minWidth: 550)
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
}

