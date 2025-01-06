//
//  DataSource.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import Foundation

// Dummy Data for Subscriptions
var subscriptions: [Subscription] = [
    Subscription(
        accountName: "Netflix",
        description: "Streaming Services",
        category: "Streaming",
        price: 15.99,
        billingDate: Date(), // Example: Today's date
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil
    ),
    Subscription(
        accountName: "Spotify",
        description: "Music Subscription",
        category: "Music",
        price: 9.99,
        billingDate: Date(), // Example: Today's date
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()) // Reminder set for 1 month later
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
        cancelReminderDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()) // Reminder set for 3 months later
    )
]

// Dummy Categories Based on Subscription Data
//let categories: [String] = Array(Set(subscriptions.map { $0.category })).sorted()
let categories: [String] = ["All Subscriptions"] + Array(Set(subscriptions.compactMap { $0.category })).sorted()

