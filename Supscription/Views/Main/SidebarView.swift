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
    let orderedCategoryNames: [String]
    
    // MARK: - View
    var body: some View {
        List(selection: $selectedCategory) {
            // General Section
            Section(header: Text("General")) {
                Label {
                    Text(AppConstants.Category.all)
                } icon: {
                    Image(systemName: "square.stack.3d.up")
                        .foregroundColor(.secondary)
                }
                .tag(AppConstants.Category.all)
            }
            
            // Categories Section
            Section(header: Text("Categories")) {
                ForEach(orderedCategoryNames, id: \.self) { category in
                    HStack {
                        Label {
                            Text(category)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundColor(selectedCategory == category ? .primary : .secondary)
                        } icon: {
                            Image(systemName: category == AppConstants.Category.uncategorized ? "doc" : "list.bullet.rectangle")
                                .foregroundColor(selectedCategory == category ? .primary : .secondary)
                        }
                        
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
