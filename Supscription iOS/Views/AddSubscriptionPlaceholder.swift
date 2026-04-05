//
//  AddSubscriptionPlaceholder.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI

struct AddSubscriptionPlaceholder: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Add Subscription",
                systemImage: "plus.circle",
                description: Text("The add subscription form will go here.")
            )
            .navigationTitle("New Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddSubscriptionPlaceholder()
}
