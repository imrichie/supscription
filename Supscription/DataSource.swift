//
//  DataSource.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import Foundation

let categories = [
    Category(name: "All Subscriptions"),
    Category(name: "Streaming"),
    Category(name: "Music"),
    Category(name: "Productivity")
]

let subscriptions: [String: [Subscription]] = [
    "All Subscriptions": [
        Subscription(accountName: "Netflix", description: "Streaming Services", price: 15.99),
        Subscription(accountName: "Spotify", description: "Music Subscription", price: 9.99),
        Subscription(accountName: "Adobe Creative Cloud", description: "Design Software", price: 19.99),
        Subscription(accountName: "Amazon Prime", description: "Shopping and streaming", price: 12.99),
        Subscription(accountName: "Apple Music", description: "Music Subscription", price: 9.99)
    ],
    "Streaming": [
        Subscription(accountName: "Netflix", description: "Streaming Services", price: 15.99),
        Subscription(accountName: "Amazon Prime", description: "Shopping and streaming", price: 12.99)
    ],
    "Music": [
        Subscription(accountName: "Spotify", description: "Music Subscription", price: 9.99),
        Subscription(accountName: "Apple Music", description: "Music Subscription", price: 9.99)
    ]
]
