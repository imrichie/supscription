//
//  ContentView.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedCategory: String? = "All Subscriptions" // Default to show all
    @State private var selectedSubscription: Subscription? = nil
    @State private var searchText: String = ""
    @State private var isAddingSubscription: Bool = false
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCategory: $selectedCategory, categories: categories)
        } content: {
            ContentListView(selectedSubscription: $selectedSubscription, subscriptions: filteredSubscriptions)
            
        } detail: {
            DetailView(subscription: selectedSubscription)
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search")
        .onChange(of: selectedCategory) { oldValue, newValue in
            searchText = ""
        }
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
    
    // Computed property to filter subscriptions dynamically
    var filteredSubscriptions: [Subscription] {
        let categoryFiltered: [Subscription]
        if let selectedCategory = selectedCategory, selectedCategory != "All Subscriptions" {
            categoryFiltered = subscriptions.filter { $0.category == selectedCategory }
        } else {
            categoryFiltered = subscriptions // Show all subscriptions if no category is selected
        }
        
        if searchText.isEmpty {
            return categoryFiltered
        } else {
            return categoryFiltered.filter {
                $0.accountName.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    ContentView()
}
