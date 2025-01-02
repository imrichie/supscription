//
//  ContentView.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedCategory: Category?
    @State private var selectedSubscription: Subscription?
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedCategory: $selectedCategory, categories: categories)
        } content: {
            ContentListView(selectedSubscription: $selectedSubscription, subscriptions: subscriptions[selectedCategory?.name ?? ""] ?? [])
            
        } detail: {
            DetailView(subscription: selectedSubscription)
        }
    }
}

#Preview {
    ContentView()
}
