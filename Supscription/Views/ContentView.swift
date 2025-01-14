//
//  ContentView.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query var subscriptions: [Subscription]
    
    @State private var selectedCategory: String? = "All Subscriptions" // Default to show all
    @State private var selectedSubscription: Subscription? = nil
    @State private var searchText: String = ""
    @State private var isAddingSubscription: Bool = false
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCategory: $selectedCategory, categories: ["Category 1", "Category 2", "Category 3"])
        } content: {
            ContentListView(selectedSubscription: $selectedSubscription)
            
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
//    var filteredSubscriptions: [Subscription] {
//        let categoryFiltered: [Subscription]
//        if let selectedCategory = selectedCategory, selectedCategory != "All Subscriptions" {
//            categoryFiltered = subscriptionData.subscriptions.filter { $0.category == selectedCategory }
//        } else {
//            categoryFiltered = subscriptionData.subscriptions // Show all subscriptions if no category is selected
//        }
//        
//        if searchText.isEmpty {
//            return categoryFiltered
//        } else {
//            return categoryFiltered.filter {
//                $0.accountName.localizedCaseInsensitiveContains(searchText) ||
//                $0.accountDescription.localizedCaseInsensitiveContains(searchText)
//            }
//        }
//    }
}

#Preview {
    ContentView()
}
