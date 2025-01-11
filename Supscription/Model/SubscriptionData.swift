//
//  SubscriptionData.swift
//  Supscription
//
//  Created by Richie Flores on 1/9/25.
//

import Foundation

class SubscriptionData: ObservableObject {
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
        Subscription(
            accountName: "Spotify",
            description: "Music Subscription",
            category: "Music",
            price: 9.99,
            billingDate: Date(),
            billingFrequency: "Monthly",
            autoRenew: true,
            remindToCancel: true,
            cancelReminderDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())
        ),
        Subscription(
            accountName: "Adobe Creative Cloud",
            description: "Design Software",
            category: "Productivity",
            price: 19.99,
            billingDate: Date(),
            billingFrequency: "Monthly",
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil
        ),
        Subscription(
            accountName: "Amazon Prime",
            description: "Shopping and streaming",
            category: "Streaming",
            price: 12.99,
            billingDate: Date(),
            billingFrequency: "Yearly",
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil
        ),
        Subscription(
            accountName: "Apple Music",
            description: "Music Subscription",
            category: "Music",
            price: 9.99,
            billingDate: Date(),
            billingFrequency: "Monthly",
            autoRenew: true,
            remindToCancel: true,
            cancelReminderDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())
        )
    ]
    
    // Dynamically generated categories from subscriptoins
    var categories: [String] {
        let baseCategories = ["All Categories"]
        let uniqueCategories = Set(subscriptions.compactMap { $0.category})
        
        return baseCategories + uniqueCategories.sorted()
    }
    
    // Add a new subscription
    func addSubscription(_ subscription: Subscription) {
        subscriptions.append(subscription)
    }
}
