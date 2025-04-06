//
//  ContentView+Computed.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/5/25.
//

import Foundation

extension ContentView {
    var uniqueCategories: [String] {
        subscriptions.uniqueCategories()
    }

    var filteredSubscriptions: [Subscription] {
        subscriptions.filtered(by: selectedCategory, searchText: searchText)
    }

    var categoryCounts: [String: Int] {
        Dictionary(grouping: subscriptions) {
            $0.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Uncategorized"
        }
        .mapValues { $0.count }
    }
    
    var orderedCategoryNames: [String] {
        subscriptions
            .uniqueCategories()
            .filter { $0 != AppConstants.Category.all }
    }

}
