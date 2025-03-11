//
//  DetailView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI

struct DetailView: View {
    // reference to Subscription model
    let subscription: Subscription?
    
    // manage state for editing mode
    @State private var isEditing: Bool = false
    
    var body: some View {
        if let subscription = subscription {
            ScrollView {
                VStack(spacing: 16) {
                    HeaderView(subscription: subscription)
                    
                    BillingInfoCard(subscription: subscription)
                    
                    if subscription.remindToCancel {
                        ReminderCard(subscription: subscription)
                    }
                    
                    SubscriptionDetailsCard(subscription: subscription)
                    
                }
                .padding()
            }
            .sheet(isPresented: $isEditing) {
                AddSubscriptionView(
                    isPresented: $isEditing,
                    isEditing: true,
                    subscriptionToEdit: subscription
                )
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Edit") {
                        isEditing.toggle()
                    }
                }
            }

        } else {
            DetailEmptyView()
        }
    }
}

