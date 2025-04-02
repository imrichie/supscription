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
    let categories: [String : Int]
    
    // MARK: - View
    var body: some View {
        List(selection: $selectedCategory) {
            // General Section
            Section(header: Text("General")) {
                Label(AppConstants.Category.all, systemImage: "rectangle.stack")
                    .labelStyle(.titleAndIcon)
                    .tag(AppConstants.Category.all)
            }
            
            // Categories Section
            Section(header: Text("Categories")) {
                ForEach(categories.keys.sorted().filter { $0 != AppConstants.Category.all }, id: \.self) { category in
                    HStack {
                        Text(category)
                        Spacer()
                        if let count = categories[category], count > 0 {
                            Text("\(count)")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(Color.gray.opacity(0.2))
                                )
                                .foregroundColor(.secondary)
                        }
                    }
                    .tag(category)
                }
            }
        }
        .navigationTitle("Categories")
        .onChange(of: selectedCategory) {
            if selectedCategory == AppConstants.Category.all {
                searchText = ""
            }
        }
    }
}
