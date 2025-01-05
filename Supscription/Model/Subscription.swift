//
//  Subscription.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import Foundation

struct Subscription: Identifiable, Hashable {
    // unique identifier
    let id = UUID()
    
    // basic info
    let accountName: String
    let description: String
    let category: String = ""
    
    // billing info
    let price: Double
    let billingDate: Date? = nil
    let billingFrequency: String = ""
    let autoRenew: Bool = true
    
    // cancellation reminder
    let remindToCancel: Bool = true
    let cancelReminderDate: Date? = nil
}
