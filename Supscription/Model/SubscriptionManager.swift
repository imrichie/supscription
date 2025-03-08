//
//  SubscriptionData.swift
//  Supscription
//
//  Created by Richie Flores on 1/9/25.
//

import Foundation
import SwiftData

class SubscriptionManager {
    private let context: ModelContext
    
    // initialize with a ModelContext
    init(context: ModelContext) {
        self.context = context
    }
    
    // fetch all subscriptions
    var subscriptions: [Subscription] {
        let fetchDescriptor = FetchDescriptor<Subscription>()
        return (try? context.fetch(fetchDescriptor)) ?? []
    }
    
    // computed property for unique categories
    var categories: [String] {
        let allCategories = subscriptions.map { $0.category }
        let uniqueCategories = Array(Set(allCategories)).filter {!$0.isEmpty}
        return ["All Subscriptions"] + uniqueCategories
    }
    
    // add a subscription
    func addSubscription(_ subscription: Subscription) {
        context.insert(subscription)
    }
    
    // delete a susbcription
    func deleteSubscription(_ subscription: Subscription) {
        context.delete(subscription)
    }
}
