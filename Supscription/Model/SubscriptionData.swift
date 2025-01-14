//
//  SubscriptionData.swift
//  Supscription
//
//  Created by Richie Flores on 1/9/25.
//

import Foundation
import SwiftData

class SubscriptionData {
    
    // Dynamically generated categories from subscriptions
    var categories: [String] {
        let baseCategories = ["All Categories"]
        let uniqueCategories = Set(sampleSubscriptions.compactMap { $0.category})
        
        return baseCategories + uniqueCategories.sorted()
    }
    
}
