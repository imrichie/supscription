//
//  Subscription+Helpers.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/30/25.
//

import Foundation
import SwiftUI

// MARK: - Subscription Array Utilities

// These helper methods extend arrays of Subscription to support common filtering and categorization logic.
extension Array where Element == Subscription {
    
    // Returns a list of unique, non-empty trimmed categories,
    // sorted alphabetically and prepended with "All Subscriptions".
    func uniqueCategories() -> [String] {
        let categories = self
            .compactMap { $0.category?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .removeCaseInsensitiveDuplicates()
            .sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }

        return ["All Subscriptions"] + categories
    }

    
    // Filters subscriptions by selected category and search text
    func filtered(by category: String?, searchText: String) -> [Subscription] {
        if !searchText.isEmpty {
            return self.filter {
                $0.accountName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        guard let category = category, category != "All Subscriptions" else {
            return self
        }
        
        return self.filter { $0.category == category }
    }
}

extension Array where Element == String {
    func removeCaseInsensitiveDuplicates() -> [String] {
        var seen = Set<String>()
        return filter {
            let lower = $0.lowercased()
            guard !seen.contains(lower) else { return false }
            seen.insert(lower)
            return true
        }
    }
}


// MARK: - Individual Subscription Helpers
extension Subscription {
    
    var displayCategory: String {
        let trimmed = category?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed?.isEmpty ?? true) ? AppConstants.Category.uncategorized : trimmed!
    }
    
    var formattedBillingDate: String? {
        billingDate?.formattedShortFriendly()
    }
    
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
    
    var autoRenewLabel: String {
        autoRenew ? "Enabled" : "Disabled"
    }
    
    var autoRenewIcon: String {
        autoRenew ? "arrow.triangle.2.circlepath" : "xmark.circle"
    }
    
    var autoRenewColor: Color {
        autoRenew ? .blue : .red
    }
}
