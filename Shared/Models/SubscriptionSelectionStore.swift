//
//  SubscriptionSelectionStore.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/23/25.
//

import SwiftUI

// Manages the currently selected subscription across the app.
//Used to enable or disable context-aware actions like Edit and Delete
@Observable
class SubscriptionSelectionStore {
    var selected: Subscription?
}
