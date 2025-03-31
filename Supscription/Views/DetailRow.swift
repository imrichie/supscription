//
//  DetailRow.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct DetailRow: View {
    var icon: String      // SF Symbol icon name
    var title: String     // Label text (e.g., "Price")
    var value: String     // The value associated with the label
    var color: Color = .primary  // Optional color for the icon
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer() // Pushes the value to the right
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6) // Gives spacing between rows
    }
}


#Preview {
    DetailRow(icon: "circle.fill", title: "Netflix", value: "Subscription")
}
