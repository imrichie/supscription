//
//  DetailView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI

struct DetailView: View {
    let subscription: Subscription?
    
    var body: some View {
        if let subscription = subscription {
            VStack {
                Text("Selected: \(subscription.accountName)")
                    .font(.largeTitle)
                Text(subscription.accountDescription)
                Text(String(format: "$%.2f", subscription.price))
                    .font(.headline)
                    .foregroundColor(.green)
            }
            .padding()
        } else {
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    // Dummy data for the preview
    let sampleSubscription = Subscription(accountName: "Netflix", accountDescription: "Streaming Services", price: 15.99)
    DetailView(subscription: sampleSubscription)
}
