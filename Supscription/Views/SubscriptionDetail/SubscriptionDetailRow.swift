//
//  DetailRow.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct SubscriptionDetailRow: View {
    // MARK: - Parameters
    
    var icon: String
    var title: String
    var value: String
    var iconColor: Color = .primary
    
    // MARK: - View
    
    var body: some View {
        HStack {
            Label {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .frame(width: 24, height: 24)
            }
            
            Spacer() // Pushes the value to the right
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6) // Gives spacing between rows
    }
}
