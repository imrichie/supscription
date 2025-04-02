//
//  SidebarView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI

struct SidebarView: View {
    // MARK: - Bindings
    @Binding var selectedCategory: String?
    @Binding var searchText: String
    
    // MARK: - Data
    let categories: [String]
    
    // MARK: - View
    var body: some View {
        List(selection: $selectedCategory) {
            // General Section
            Section(header: Text("General")) {
                Text(AppConstants.Category.all)
                    .tag(AppConstants.Category.all)
                    .onTapGesture {
                        if selectedCategory == AppConstants.Category.all {
                            searchText = ""
                        }
                        selectedCategory = AppConstants.Category.all
                    }
            }
            
            // Categories Section
            Section(header: Text("Categories")) {
                ForEach(categories.filter { $0 != AppConstants.Category.all }, id: \.self) { category in
                    Text(category)
                        .tag(category)
                }
            }
        }
        .navigationTitle("Categories")
    }
}
