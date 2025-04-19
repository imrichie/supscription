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
            
            if let urlString = subscription.accountURL,
               let url = URL(string: "https://\(urlString)") {
                Link(destination: url) {
                    SubscriptionDetailRow(
                        icon: "link",
                        title: "Account URL",
                        value: urlString,
                        iconColor: .blue
                    )
                }
                .buttonStyle(.plain) // Removes the default blue link styling
                .onHover { hovering in
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
        }
        .cardBackground()
    }
}
