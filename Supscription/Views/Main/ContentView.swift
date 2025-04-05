//
//  ContentView.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Data
    
    @Environment(\.modelContext) private var context
    @Query var subscriptions: [Subscription]
    
    // MARK: - State
    
    @State private var selectedCategory: String? = AppConstants.Category.all
    @State private var selectedSubscription: Subscription? = nil
    @State private var searchText: String = ""
    @State private var isAddingSubscription: Bool = false
   
    // MARK: - Computed Properties
    
    // computes a list of unique categories and ensures All Categories is always first
    var uniqueCategories: [String] {
        subscriptions.uniqueCategories()
    }
    
    // filters subscriptions based on the currently selected category
    var filteredSubscriptions: [Subscription] {
        subscriptions.filtered(by: selectedCategory, searchText: searchText)
    }
    
    var categoryCounts: [String: Int] {
        Dictionary(grouping: subscriptions) { $0.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Uncategorized"}
            .mapValues{ $0.count }
    }
    
    // MARK: - View
    var body: some View {
        NavigationSplitView {
            SidebarView(
                selectedCategory: $selectedCategory,
                searchText: $searchText,
                categories: categoryCounts)
                .frame(minWidth: 200)
        } content: {
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
                    searchText: $searchText)
                .frame(minWidth: 300)
                
            }
        } detail: {
            if subscriptions.isEmpty {
                OnboardingEmptyStateView(isAddingSubscription: $isAddingSubscription)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SubscriptionDetailView(selectedSubscription: $selectedSubscription, allSubscriptions: subscriptions)
                    .frame(minWidth: 550)
            }
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search")
        .onChange(of: selectedCategory) { oldValue, newValue in
            searchText = "" // reset search when any category is selected
        }
        .navigationTitle(selectedCategory ?? AppConstants.Category.all)
        .navigationSubtitle("\(filteredSubscriptions.count) Items")
//        .task {
//            #if DEBUG
//            DebugSeeder.seedIfNeeded(in: context)
//            #endif
//        }
        .sheet(isPresented: $isAddingSubscription) {
            AddSubscriptionView(
                isPresented: $isAddingSubscription,
                existingSubscriptions: subscriptions,
                onAdd: { newSubscription in
                    selectedSubscription = newSubscription
                }
            )
        }
    }
}
