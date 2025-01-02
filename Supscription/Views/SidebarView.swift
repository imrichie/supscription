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
        List(categories, selection: $selectedCategory) { category in
            Text(category.name)
                .tag(category)
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
