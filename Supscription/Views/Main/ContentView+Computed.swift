//
//  ContentView+Computed.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/5/25.
//

import Foundation

extension ContentView {
    var selectedCategory: String? {
        if case .subscriptions(let category) = selectedDestination {
            return category
        }
        return nil
    }

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

    var navigationTitle: String {
        switch selectedDestination {
        case .dashboard:
            return "Dashboard"
        case .subscriptions(let category):
            return category ?? AppConstants.Category.all
        }
    }

    var navigationSubtitle: String {
        switch selectedDestination {
        case .dashboard:
            return "\(subscriptions.count) Subscriptions"
        case .subscriptions:
            return "\(filteredSubscriptions.count) Items"
        }
    }
}
