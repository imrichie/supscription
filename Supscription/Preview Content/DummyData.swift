//
//  DummyData.swift
//  Supscription
//
//  Created by Richie Flores on 1/10/25.
//

import Foundation

let sampleSubscriptions: [Subscription] = [
    Subscription(
        accountName: "Netflix",
        accountDescription: "Streaming Services",
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
        accountDescription: "Music Subscription",
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
        accountDescription: "Design Software",
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
        accountDescription: "Shopping and streaming",
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
        accountDescription: "Music Subscription",
        category: "Music",
        price: 9.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())
    )
]
