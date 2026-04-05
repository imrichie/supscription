//
//  iOSContentView.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/3/26.
//

import SwiftUI
import SwiftData

struct iOSContentView: View {
    @Query(sort: \Subscription.accountName) private var subscriptions: [Subscription]

    var body: some View {
        NavigationStack {
            List(subscriptions) { subscription in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(subscription.accountName)
                            .font(.headline)
                        if let category = subscription.category {
                            Text(category)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Text(subscription.price, format: .currency(code: "USD"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Supscription")
            .overlay {
                if subscriptions.isEmpty {
                    ContentUnavailableView(
                        "No Subscriptions",
                        systemImage: "creditcard",
                        description: Text("Subscriptions added on your Mac will appear here via iCloud.")
                    )
                }
            }
        }
    }
}

#Preview {
    iOSContentView()
        .modelContainer(for: Subscription.self, inMemory: true)
}
