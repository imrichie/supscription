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
    let categories: [String : Int]
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
                    HStack {
                        Text(category)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(selectedDestination == .subscriptions(category: category) ? .primary : .secondary)

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
