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
    
    // fetches all subscriptions from SwiftData
    @Query var subscriptions: [Subscription]
    
    // MARK: - State
    
    @State private var selectedCategory: String? = AppConstants.Category.all
    @State private var selectedSubscription: Subscription? = nil
    @State private var searchText: String = ""
   
    // MARK: - Computed Properties
    
    // computes a list of unique categories and ensures All Categories is always first
    var uniqueCategories: [String] {
        subscriptions.uniqueCategories()
    }
    
    // filters subscriptions based on the currently selected category
    var filteredSubscriptions: [Subscription] {
        subscriptions.filtered(by: selectedCategory, searchText: searchText)
    }
    
    // MARK: - View
    var body: some View {
        NavigationSplitView {
            SidebarView(
                selectedCategory: $selectedCategory,
                searchText: $searchText,
                categories: uniqueCategories)
                .frame(minWidth: 175)
        } content: {
            ContentListView(
                subscriptions: filteredSubscriptions,
                selectedSubscription: $selectedSubscription,
                searchText: $searchText)
                .frame(minWidth: 250, idealWidth: 300)
        } detail: {
            SubscriptionDetailView(selectedSubscription: $selectedSubscription, allSubscriptions: subscriptions)
                .frame(minWidth: 550)
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search")
        .onChange(of: selectedCategory) { oldValue, newValue in
            searchText = "" // reset search when any category is selected
        }
        .navigationTitle(selectedCategory ?? AppConstants.Category.all)
        .navigationSubtitle("\(filteredSubscriptions.count) Items")
    }
}
