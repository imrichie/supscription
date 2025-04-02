//
//  SubDetailsCard.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct SubscriptionDetailsCard: View {
    // MARK: - Parameters
    
    let subscription: Subscription
    
    var body: some View {
        VStack {
            SubscriptionDetailRow(
                icon: "folder.fill",
                title: "Category",
                value: subscription.displayCategory,
                iconColor: .purple)
        }
        .cardBackground()
    }
}
