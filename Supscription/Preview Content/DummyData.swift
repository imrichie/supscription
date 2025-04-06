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
        remindToCancel: false,
        cancelReminderDate: nil,
        logoName: "netflix"
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
        cancelReminderDate: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
        logoName: "spotify"
    ),
    Subscription(
        accountName: "Adobe Creative Cloud",
        accountDescription: "Design and Productivity Software",
        category: "Productivity",
        price: 52.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        logoName: "adobe"
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
        cancelReminderDate: nil,
        logoName: "amazon"
    ),
    Subscription(
        accountName: "Notion Plus",
        accountDescription: "Note-taking and productivity tool",
        category: "Productivity",
        price: 4.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        logoName: "notion"
    ),
    Subscription(
        accountName: "YouTube Premium",
        accountDescription: "Ad-free YouTube and Music",
        category: "Entertainment",
        price: 11.99,
        billingDate: Date(),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        logoName: "youtube"
    )
]
