//
//  DummyData.swift
//  Supscription
//
//  Created by Richie Flores on 1/10/25.
//

import Foundation

// Helper to produce a billing date N days in the past so that nextBillingDate
// computes a natural upcoming due date relative to today.
private func daysAgo(_ n: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date()
}

let sampleSubscriptions: [Subscription] = [

    // MARK: - Streaming
    Subscription(
        accountName: "Netflix",
        category: "Streaming",
        price: 15.99,
        billingDate: daysAgo(25),       // due in ~5 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "netflix.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Disney+",
        category: "Streaming",
        price: 13.99,
        billingDate: daysAgo(29),       // due in ~1 day
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: nil,
        accountURL: "disneyplus.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Hulu",
        category: "Streaming",
        price: 17.99,
        billingDate: daysAgo(27),       // due in ~3 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "hulu.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Amazon Prime",
        category: "Streaming",
        price: 139.00,
        billingDate: daysAgo(330),      // yearly — due in ~35 days
        billingFrequency: "Yearly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "amazon.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "YouTube Premium",
        category: "Entertainment",
        price: 13.99,
        billingDate: daysAgo(5),        // due in ~25 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "youtube.com",
        lastModified: Date()
    ),

    // MARK: - Music
    Subscription(
        accountName: "Spotify",
        category: "Music",
        price: 9.99,
        billingDate: daysAgo(12),       // due in ~18 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "spotify.com",
        lastModified: Date()
    ),

    // MARK: - Productivity
    Subscription(
        accountName: "Adobe Creative Cloud",
        category: "Productivity",
        price: 54.99,
        billingDate: daysAgo(28),       // due in ~2 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: nil,
        accountURL: "adobe.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Notion",
        category: "Productivity",
        price: 4.99,
        billingDate: daysAgo(18),       // due in ~12 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "notion.so",
        lastModified: Date()
    ),
    Subscription(
        accountName: "1Password",
        category: "Productivity",
        price: 2.99,
        billingDate: daysAgo(7),        // due in ~23 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "1password.com",
        lastModified: Date()
    ),

    // MARK: - Developer Tools
    Subscription(
        accountName: "GitHub",
        category: "Developer Tools",
        price: 7.99,
        billingDate: daysAgo(22),       // due in ~8 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "github.com",
        lastModified: Date()
    ),

    // MARK: - Storage
    Subscription(
        accountName: "iCloud+",
        category: "Storage",
        price: 2.99,
        billingDate: daysAgo(3),        // due in ~27 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "icloud.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Dropbox",
        category: "Storage",
        price: 11.99,
        billingDate: daysAgo(26),       // due in ~4 days
        billingFrequency: "Monthly",
        autoRenew: false,
        remindToCancel: true,
        cancelReminderDate: nil,
        accountURL: "dropbox.com",
        lastModified: Date()
    ),

    // MARK: - Gaming
    Subscription(
        accountName: "Xbox Game Pass",
        category: "Gaming",
        price: 14.99,
        billingDate: daysAgo(8),        // due in ~22 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "xbox.com",
        lastModified: Date()
    ),

    // MARK: - Utilities
    Subscription(
        accountName: "AT&T Wireless",
        category: "Utilities",
        price: 95.00,
        billingDate: daysAgo(28),       // due in ~2 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "att.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Xfinity",
        category: "Utilities",
        price: 79.99,
        billingDate: daysAgo(14),       // due in ~16 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "xfinity.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "PG&E",
        category: "Utilities",
        price: 130.00,
        billingDate: daysAgo(20),       // due in ~10 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "pge.com",
        lastModified: Date()
    ),

    // MARK: - News
    Subscription(
        accountName: "New York Times",
        category: "News",
        price: 17.00,
        billingDate: daysAgo(10),       // due in ~20 days
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "nytimes.com",
        lastModified: Date()
    ),
]
