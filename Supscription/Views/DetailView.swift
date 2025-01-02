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
                Text(subscription.description)
                Text(String(format: "$%.2f", subscription.price))
                    .font(.headline)
                    .foregroundColor(.green)
            }
            .padding()
        } else {
            ContentUnavailableView("No Subscription Selected", systemImage: "doc.text.image.fill")
        }
    }
}

#Preview {
    // Dummy data for the preview
    let sampleSubscription = Subscription(accountName: "Netflix", description: "Streaming Services", price: 15.99)
    DetailView(subscription: sampleSubscription)
}
