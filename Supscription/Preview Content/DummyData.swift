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
        accountDescription: "Streaming Service",
        category: "Streaming",
        price: 15.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: nil
    ),
    Subscription(
        accountName: "Spotify",
        accountDescription: "Music Streaming Service",
        category: "Music",
        price: 9.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())
    ),
    Subscription(
        accountName: "Adobe",
        accountDescription: "Design and Productivity Software",
        category: "Productivity",
        price: 52.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: nil
    ),
    Subscription(
        accountName: "Amazon Prime",
        accountDescription: "Shopping & Video Streaming",
        category: "Streaming",
        price: 12.99,
        billingDate: Date(),
        billingFrequency: "Yearly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil
    ),
    Subscription(
        accountName: "Notion",
        accountDescription: "Note-taking and productivity tool",
        category: "Productivity",
        price: 4.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil
    ),
    Subscription(
        accountName: "YouTube",
        accountDescription: "Ad-free YouTube and Music",
        category: "Entertainment",
        price: 11.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil
    )
]
