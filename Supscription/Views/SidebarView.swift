//
//  SidebarView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedCategory: String? // Updated to match the `ContentView`
    @Binding var searchText: String
    let categories: [String]              // Updated to a list of category names
    
    var body: some View {
        List(selection: $selectedCategory) {
            // General Section
            Section(header: Text("General")) {
                Text("All Subscriptions")
                    .tag("All Subscriptions") // Match the "All Subscriptions" category
                    .onTapGesture {
                        if selectedCategory == "All Subscriptions" {
                            searchText = ""
                        }
                        selectedCategory = "All Subscriptions"
                    }
            }
            
            // Categories Section
            Section(header: Text("Categories")) {
                ForEach(categories.filter { $0 != "All Subscriptions" }, id: \.self) { category in
                    Text(category)
                        .tag(category)
                }
            }
        }
        .navigationTitle("Categories")
    }
}
