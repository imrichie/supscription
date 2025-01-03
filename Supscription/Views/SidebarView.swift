//
//  SidebarView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selectedCategory: Category?
    let categories: [Category]
    
    var body: some View {
        List(selection: $selectedCategory) {
            // All Subscriptions Section
            if let allSubscriptions = categories.first(where: { $0.name == "All Subscriptions" }) {
                Section(header: Text("General")) {
                    Text(allSubscriptions.name)
                        .tag(allSubscriptions)
                }
            }
            
            // Categories Section
            Section(header: Text("Categories")) {
                ForEach(categories.filter { $0.name != "All Subscriptions" }) { category in
                    Text(category.name)
                        .tag(category)
                }
            }
            
            // Work Section
            Section(header: Text("Work")) {
                
            }
            
            // Personal Section
            Section(header: Text("Personal")) {
                
            }
        }
    }
}
    
#Preview {
    @Previewable @State var selectedCategory: Category? = nil
    
    let sampleCategories = [
        Category(name: "All Subscriptions"),
        Category(name: "Streaming"),
        Category(name: "Music"),
        Category(name: "Productivity")
    ]

    return SidebarView(
        selectedCategory: $selectedCategory,
        categories: sampleCategories
    )
}
