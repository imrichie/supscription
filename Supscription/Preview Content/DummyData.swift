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
        category: "Streaming",
        price: 15.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: false,
        remindToCancel: true,
        cancelReminderDate: nil,
        lastModified: Date()
    ),
    Subscription(
        accountName: "Spotify",
        category: "Music",
        price: 9.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
        lastModified: Date()
    ),
    Subscription(
        accountName: "Adobe",
        category: "Productivity",
        price: 52.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: nil,
        lastModified: Date()
    ),
    Subscription(
        accountName: "Amazon Prime",
        category: "Streaming",
        price: 12.99,
        billingDate: Date(),
        billingFrequency: "Yearly",
        autoRenew: false,
        remindToCancel: false,
        cancelReminderDate: nil,
        lastModified: Date()
    ),
    Subscription(
        accountName: "Notion",
        category: "Productivity",
        price: 4.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        lastModified: Date()
    ),
    Subscription(
        accountName: "YouTube",
        category: "Entertainment",
        price: 11.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        lastModified: Date()
    )
]
