//
//  Constants.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/30/25.
//

import Foundation
import SwiftUI

enum AppConstants {
    enum Category {
        static let all = "All Subscriptions"
        static let uncategorized = "Uncategorized"
    }
    
    enum UI {
        static let defaultAnimationDuration: TimeInterval = 0.2
    }
    
    enum KeyboardShortcuts {
        static let newSubscriptionKey = KeyEquivalent("n")
        static let editSubscriptionKey = KeyEquivalent("e")
        static let deleteSubscriptionKey = KeyEquivalent("d")
    }
    
    enum AppText {
        static let searchPrompt = "Search"
        static let addSubscription = "Add Subscription"
        static let sort = "Sort"
        static let deleteConfirmationTitle = "Delete Subscription"
        static let deleteSuccessMessage = "Subscription Deleted"
        static func deleteConfirmationMessage(for name: String) -> String {
            "Are you sure you want to delete \(name)? This action cannot be undone."
        }
        static let noSubscriptionSelectedTitle = "No Subscription Selected"
        static let noSubscriptionSelectedMessage = "Please select a subscription to edit or delete."
        static let noSubscriptionFoundTitle = "No Subscriptions Found"
        static let noSubscriptionFoundMessage = "Your search did not match any subscriptions."
    }
    
    enum AppAnimation {
        static let deleteSpring = Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
    
    // Add more groups as needed
    // enum API, enum defaults, enum Icons, etc.,
}
