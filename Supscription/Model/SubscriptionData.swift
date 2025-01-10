//
//  SubscriptionData.swift
//  Supscription
//
//  Created by Richie Flores on 1/9/25.
//

import Foundation

class SubscritionData: ObservableObject {
    @Published var subscriptions: [Subscription] = [
        Subscription(
            accountName: "Netflix",
            description: "Streaming Services",
            category: "Streaming",
            price: 15.99,
            billingDate: Date(),
            billingFrequency: "Monthly",
            autoRenew: false,
            remindToCancel: false,
            cancelReminderDate: nil
        ),
        // TODO: Add other dummy subscription data here
    ]
    
    // Dynamically generated categories
    var categories: [String] {
        let allCategories = ["All Subscriptions"] + Set(subscriptions.compactMap { $0.category }).sorted()
        return allCategories
    }
}

