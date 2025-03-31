//
//  DetailEmptyView.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/10/25.
//

import SwiftUI

struct EmptySubscriptionDetailView: View {
    var body: some View {
        VStack {
            Spacer() // Push content to the center
            
            Image(systemName: "rectangle.stack.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray.opacity(0.6)) // Subtle gray for the icon
                .padding(.bottom, 12)
            
            Text("No Subscription Selected")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.bottom, 6)
            
            Text("Select a subscription from the list to see its details.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

#Preview {
    EmptySubscriptionDetailView()
}
