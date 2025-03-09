//
//  Subscription.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import Foundation
import SwiftData

@Model
class Subscription {
    
    // basic info
    var accountName: String
    var accountDescription: String
    var category: String
    
    // billing info
    var price: Double
    var billingDate: Date?
    var billingFrequency: String
    var autoRenew: Bool
    
    // cancellation reminder
    var remindToCancel: Bool
    var cancelReminderDate: Date?
    
    // Custom Initializer
    init(
        accountName: String,
        accountDescription: String = "",
        category: String = "",
        price: Double,
        billingDate: Date? = nil,
        billingFrequency: String = "",
        autoRenew: Bool = true,
        remindToCancel: Bool = false,
        cancelReminderDate: Date? = nil
    ) {
        self.accountName = accountName
        self.accountDescription = accountDescription
        self.category = category
        self.price = price
        self.billingDate = billingDate
        self.billingFrequency = billingFrequency
        self.autoRenew = autoRenew
        self.remindToCancel = remindToCancel
        self.cancelReminderDate = cancelReminderDate
    }
}

