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
            SidebarView(selectedCategory: $selectedCategory, categories: ["All subscriptions"])
        } content: {
            ContentListView(subscriptions: subscriptions, selectedSubscription: $selectedSubscription)
            
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
}

#Preview {
    ContentView()
}
