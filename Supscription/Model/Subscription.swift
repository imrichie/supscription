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
    var accountDescription: String? = nil
    var category: String? = nil
    
    // billing info
    var price: Double = 0.0
    var billingDate: Date? = nil
    var billingFrequency: String = "Monthly"
    var autoRenew: Bool = true
    
    // cancellation reminder
    var remindToCancel: Bool = false
    var cancelReminderDate: Date? = nil
    
    // Custom Initializer
    init(
        accountName: String,
        accountDescription: String?,
        category: String?,
        price: Double,
        billingDate: Date?,
        billingFrequency: String,
        autoRenew: Bool,
        remindToCancel: Bool,
        cancelReminderDate: Date?
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

