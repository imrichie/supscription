//
//  SubDetailsCard.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct SubscriptionDetailsCard: View {
    let subscription: Subscription
    
    
    var body: some View {
        VStack {
            DetailRow(
                icon: "folder.fill",
                title: "Category",
                value: displayCategory,
                color: .purple)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(nsColor: .windowBackgroundColor)))
    }
    
    private var displayCategory: String {
        let trimmed = subscription.category?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (trimmed?.isEmpty ?? true) ? "Uncategorized" : trimmed!
    }
}

