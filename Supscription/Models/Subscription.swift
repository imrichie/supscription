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
    var category: String? = nil
    var logoName: String? = nil
    var accountURL: String? = nil
    
    // billing info
    var price: Double = 0.0
    var billingDate: Date? = nil
    var billingFrequency: String = BillingFrequency.none.rawValue
    var autoRenew: Bool = true
    
    // cancellation reminder
    var remindToCancel: Bool = false
    var cancelReminderDate: Date? = nil
    
    var lastModified: Date = Date()
    
    // Initializer
    init(
        accountName: String,
        category: String?,
        price: Double,
        billingDate: Date?,
        billingFrequency: String,
        autoRenew: Bool,
        remindToCancel: Bool,
        cancelReminderDate: Date?,
        logoName: String? = nil,
        accountURL: String? = nil,
        lastModified: Date?
    ) {
        self.accountName = accountName
        self.category = category
        self.price = price
        self.billingDate = billingDate
        self.billingFrequency = billingFrequency
        self.autoRenew = autoRenew
        self.remindToCancel = remindToCancel
        self.cancelReminderDate = cancelReminderDate
        self.logoName = logoName
        self.accountURL = accountURL
        self.lastModified = lastModified ?? Date()
    }
}
