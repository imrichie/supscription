//
//  SubscriptionData.swift
//  Supscription
//
//  Created by Richie Flores on 1/9/25.
//

import Foundation
import SwiftData

class SubscriptionData {
    // holds all subscriptions
    var subscriptions: [Subscription] = []
    
    // Dynamically generated categories from subscriptions
    var categories: [String] {
        // default for empty state
        guard !subscriptions.isEmpty else { return ["No Categories"] }
        
        let baseCategories = ["All Categories"]
        let uniqueCategories = Set(sampleSubscriptions.compactMap { $0.category})
        return baseCategories + uniqueCategories.sorted()
    }
    
    // initialize with optional sample data
    init(initialSubscription: [Subscription] = []) {
        self.subscriptions = initialSubscription
    }
    
    // add a new subscription
    func addSubscription(_ subscription: Subscription) {
        subscriptions.append(subscription)
    }
    
    // remove a subscription
    func removeSubscription(_ subscription: Subscription) {
        subscriptions.removeAll { $0.id == subscription.id }
    }
}
