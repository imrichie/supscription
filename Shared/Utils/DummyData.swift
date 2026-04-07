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

private func monthsAgo(_ n: Int, day: Int = 15) -> Date {
    let calendar = Calendar.current
    guard let base = calendar.date(byAdding: .month, value: -n, to: Date()) else { return Date() }
    var components = calendar.dateComponents([.year, .month], from: base)
    components.day = min(day, 28)
    return calendar.date(from: components) ?? base
}

let sampleSubscriptions: [Subscription] = [

    // MARK: - Streaming
    Subscription(
        accountName: "Netflix",
        category: "Streaming",
        price: 15.99,
        billingDate: daysAgo(25),
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
        billingDate: daysAgo(29),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
        accountURL: "disneyplus.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Hulu",
        category: "Streaming",
        price: 17.99,
        billingDate: daysAgo(27),
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
        billingDate: monthsAgo(8, day: 10),
        billingFrequency: "Yearly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "amazon.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "YouTube Premium",
        category: "Streaming",
        price: 13.99,
        billingDate: daysAgo(5),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "youtube.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Max",
        category: "Streaming",
        price: 16.99,
        billingDate: daysAgo(18),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
        accountURL: "max.com",
        lastModified: Date()
    ),

    // MARK: - Music
    Subscription(
        accountName: "Spotify",
        category: "Music",
        price: 10.99,
        billingDate: daysAgo(12),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "spotify.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Apple Music",
        category: "Music",
        price: 10.99,
        billingDate: daysAgo(20),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "apple.com/apple-music",
        lastModified: Date()
    ),

    // MARK: - Productivity
    Subscription(
        accountName: "Adobe Creative Cloud",
        category: "Productivity",
        price: 54.99,
        billingDate: daysAgo(28),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
        accountURL: "adobe.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Notion",
        category: "Productivity",
        price: 96.00,
        billingDate: monthsAgo(4, day: 22),
        billingFrequency: "Yearly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "notion.so",
        lastModified: Date()
    ),
    Subscription(
        accountName: "1Password",
        category: "Productivity",
        price: 35.88,
        billingDate: monthsAgo(9, day: 5),
        billingFrequency: "Yearly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "1password.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Todoist",
        category: "Productivity",
        price: 4.00,
        billingDate: daysAgo(15),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "todoist.com",
        lastModified: Date()
    ),

    // MARK: - Developer Tools
    Subscription(
        accountName: "GitHub",
        category: "Developer Tools",
        price: 7.99,
        billingDate: daysAgo(22),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "github.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "ChatGPT Plus",
        category: "Developer Tools",
        price: 20.00,
        billingDate: daysAgo(10),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .day, value: 18, to: Date()),
        accountURL: "chat.openai.com",
        lastModified: Date()
    ),

    // MARK: - Storage
    Subscription(
        accountName: "iCloud+",
        category: "Storage",
        price: 2.99,
        billingDate: daysAgo(3),
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
        price: 119.88,
        billingDate: monthsAgo(6, day: 1),
        billingFrequency: "Yearly",
        autoRenew: false,
        remindToCancel: true,
        cancelReminderDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
        accountURL: "dropbox.com",
        lastModified: Date()
    ),

    // MARK: - Gaming
    Subscription(
        accountName: "Xbox Game Pass",
        category: "Gaming",
        price: 14.99,
        billingDate: daysAgo(8),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "xbox.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "PlayStation Plus",
        category: "Gaming",
        price: 59.99,
        billingDate: monthsAgo(3, day: 18),
        billingFrequency: "Yearly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "playstation.com",
        lastModified: Date()
    ),

    // MARK: - Health & Fitness
    Subscription(
        accountName: "Strava",
        category: "Health",
        price: 79.99,
        billingDate: monthsAgo(5, day: 12),
        billingFrequency: "Yearly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "strava.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "Headspace",
        category: "Health",
        price: 12.99,
        billingDate: daysAgo(16),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "headspace.com",
        lastModified: Date()
    ),

    // MARK: - News
    Subscription(
        accountName: "New York Times",
        category: "News",
        price: 17.00,
        billingDate: daysAgo(10),
        billingFrequency: "Monthly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "nytimes.com",
        lastModified: Date()
    ),
    Subscription(
        accountName: "The Athletic",
        category: "News",
        price: 71.99,
        billingDate: monthsAgo(7, day: 25),
        billingFrequency: "Yearly",
        autoRenew: true,
        remindToCancel: false,
        cancelReminderDate: nil,
        accountURL: "theathletic.com",
        lastModified: Date()
    ),
]
