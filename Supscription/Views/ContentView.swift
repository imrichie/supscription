//
//  ContentView.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedCategory: Category? = categories.first
    @State private var selectedSubscription: Subscription?
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
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search subscriptions")
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
    
    // Filtered subscriptions based on search query
    var filteredSubscriptions: [Subscription]? {
        guard let categoryName = selectedCategory?.name else {
            return nil // No category selected
        }

        guard let subscriptionsForCategory = subscriptions[categoryName] else {
            return nil // No subscriptions for the selected category
        }

        // Filter subscriptions by search text
        if searchText.isEmpty {
            return subscriptionsForCategory
        } else {
            return subscriptionsForCategory.filter {
                $0.accountName.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview {
    ContentView()
}
