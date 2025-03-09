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
    @State private var isAddingSubscription: Bool = false
    
    // computes a list of unique categories and ensures All Categories is always first
    var uniqueCategories: [String] {
        let categories = Set(subscriptions.map { $0.category}).sorted()
        return ["All Subscriptions"] + categories
    }
    
    // filters subscriptions based on the currently selected category
    var filteredSubscriptions: [Subscription] {
        // if the selected category is already All Subscriptions then just return the fetched array
        // otherwise return a filtered array based on the selected category
        if selectedCategory == "All Subscriptions" {
            return subscriptions
        } else {
            return subscriptions.filter { $0.category == selectedCategory ?? ""}
        }
    }
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCategory: $selectedCategory, categories: uniqueCategories)
        } content: {
            ContentListView(subscriptions: filteredSubscriptions, selectedSubscription: $selectedSubscription)
            
        } detail: {
            DetailView(subscription: selectedSubscription)
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    isAddingSubscription = true
                }) {
                    Label("Add subscription", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingSubscription) {
            AddSubscriptionView(isPresented: $isAddingSubscription)
        }
    }
}

#Preview {
    ContentView()
}
