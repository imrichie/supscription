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
    
    var nextBillingDate: Date? {
        guard let billingDate = billingDate else { return nil }
        guard let frequency = BillingFrequency(rawValue: billingFrequency) else { return billingDate }

        var nextDate = billingDate
        let now = Date()
        let calendar = Calendar.current

        while nextDate < now {
            switch frequency {
            case .daily:
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
            case .weekly:
                nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: nextDate) ?? nextDate
            case .monthly:
                nextDate = calendar.date(byAdding: .month, value: 1, to: nextDate) ?? nextDate
            case .quarterly:
                nextDate = calendar.date(byAdding: .month, value: 3, to: nextDate) ?? nextDate
            case .yearly:
                nextDate = calendar.date(byAdding: .year, value: 1, to: nextDate) ?? nextDate
            case .none:
                return billingDate
            }
        }

        return nextDate
    }
}
