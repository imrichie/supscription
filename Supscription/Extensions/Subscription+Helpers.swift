//
//  Subscription+Helpers.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/30/25.
//

import Foundation
// MARK: - Subscription Array Utilities
// These helper methods extend arrays of Subscription to support common filtering and categorization logic.

extension Array where Element == Subscription {
    
    // Returns a list of unique, non-empty trimmed categories,
    // sorted alphabetically and prepended with "All Subscriptions".
    func uniqueCategories() -> [String] {
        let categories = Set(
            self.compactMap { $0.category?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        ).sorted()
        
        return ["All Subscriptions"] + categories
    }
    
    // Filters subscriptions by selected category and search text
    func filtered(by category: String?, searchText: String) -> [Subscription] {
        if !searchText.isEmpty {
            return self.filter {
                $0.accountName.localizedCaseInsensitiveContains(searchText) ||
                $0.accountDescription?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        guard let category = category, category != "All Subscriptions" else {
            return self
        }
        
        return self.filter { $0.category == category }
    }
}
