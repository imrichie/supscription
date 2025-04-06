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
    @Attribute(.unique) var id: UUID = UUID()
    
    // basic info
    var accountName: String
    var accountDescription: String? = nil
    var category: String? = nil
    var logoName: String? = nil
    
    // billing info
    var price: Double = 0.0
    var billingDate: Date? = nil
    var billingFrequency: String = BillingFrequency.monthly.rawValue
    var autoRenew: Bool = true
    
    // cancellation reminder
    var remindToCancel: Bool = false
    var cancelReminderDate: Date? = nil
    
    // Initializer
    init(
        accountName: String,
        accountDescription: String?,
        category: String?,
        price: Double,
        billingDate: Date?,
        billingFrequency: String,
        autoRenew: Bool,
        remindToCancel: Bool,
        cancelReminderDate: Date?,
        logoName: String? = nil
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
        self.logoName = logoName
    }
}
