//
//  ContentView.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // fetches all subscriptions from SwiftData
    @Query var subscriptions: [Subscription]
    
    // state management
    @State private var selectedCategory: String? = "All Subscriptions"
    @State private var selectedSubscription: Subscription? = nil
    @State private var searchText: String = ""
   
    
    // computes a list of unique categories and ensures All Categories is always first
    var uniqueCategories: [String] {
        let categories = Set(subscriptions.map { $0.category}).sorted()
        return ["All Subscriptions"] + categories
    }
    
    // filters subscriptions based on the currently selected category
    var filteredSubscriptions: [Subscription] {
        if !searchText.isEmpty {
            return subscriptions.filter {
                $0.accountName.localizedCaseInsensitiveContains(searchText) ||
                $0.accountDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return selectedCategory == "All Subscriptions"
        ? subscriptions : subscriptions.filter { $0.category == selectedCategory ?? ""}
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCategory: $selectedCategory, searchText: $searchText, categories: uniqueCategories)
        } content: {
            ContentListView(subscriptions: filteredSubscriptions, selectedSubscription: $selectedSubscription, searchText: $searchText)
        } detail: {
            DetailView(subscription: selectedSubscription)
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search")
        .onChange(of: selectedCategory) { oldValue, newValue in
            searchText = "" // reset search when any category is selected
        }        
    }
}

#Preview {
    ContentView()
}
