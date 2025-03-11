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
        NavigationStack {
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
                        isEditing: true,
                        subscriptionToEdit: subscription,
                        isPresented: $isEditing
                    )
                }
                .toolbar {
                    // Show Edit button only when subscription is available
                    ToolbarItem {
                        Button(isEditing ? "Done" : "Edit") {
                            isEditing.toggle()
                        }
                    }
                }            
            }
        }
        // TODO: Add dynamic edit in toolbar
    }
}

