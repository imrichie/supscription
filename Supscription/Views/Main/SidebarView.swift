//
//  SidebarView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI

struct SidebarView: View {
    // MARK: - Bindings
    @Binding var selectedDestination: SidebarDestination
    @Binding var searchText: String

    // MARK: - Data
    let orderedCategoryNames: [String]

    // MARK: - View
    var body: some View {
        List(selection: $selectedDestination) {
            // General Section
            Section(header: Text("General")) {
                Label {
                    Text("Dashboard")
                } icon: {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundColor(.secondary)
                }
                .tag(SidebarDestination.dashboard)

                Label {
                    Text(AppConstants.Category.all)
                } icon: {
                    Image(systemName: "square.stack.3d.up")
                        .foregroundColor(.secondary)
                }
                .tag(SidebarDestination.subscriptions(category: AppConstants.Category.all))
            }

            // Categories Section
            Section(header: Text("Categories")) {
                ForEach(orderedCategoryNames, id: \.self) { category in
                    Text(category)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(selectedDestination == .subscriptions(category: category) ? .primary : .secondary)
                        .tag(SidebarDestination.subscriptions(category: category))
                }
            }
        }
        .navigationTitle("Categories")
        .onChange(of: selectedDestination) {
            if selectedDestination == .subscriptions(category: AppConstants.Category.all) {
                searchText = ""
            }
        }
    }
}
