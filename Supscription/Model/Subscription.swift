//
//  Subscription.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import Foundation

struct Subscription: Identifiable, Hashable {
    // unique identifier
    let id: UUID
    
    // basic info
    let accountName: String
    let description: String
    let category: String
    
    // billing info
    let price: Double
    let billingDate: Date?
    let billingFrequency: String
    let autoRenew: Bool
    
    // cancellation reminder
    let remindToCancel: Bool
    let cancelReminderDate: Date?
    
    // Custom Initializer
    init(
        accountName: String,
        description: String = "",
        category: String = "",
        price: Double,
        billingDate: Date? = nil,
        billingFrequency: String = "",
        autoRenew: Bool = true,
        remindToCancel: Bool = true,
        cancelReminderDate: Date? = nil
    ) {
        self.id = UUID()
        self.accountName = accountName
        self.description = description
        self.category = category
        self.price = price
        self.billingDate = billingDate
        self.billingFrequency = billingFrequency
        self.autoRenew = autoRenew
        self.remindToCancel = remindToCancel
        self.cancelReminderDate = cancelReminderDate
    }
}

