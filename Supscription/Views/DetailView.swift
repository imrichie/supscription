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
    @Environment(\.modelContext) var modelContext
    
    // manage state
    @State private var isEditing: Bool = false
    @State private var showDeleteConfirmation = false
    
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
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        isEditing.toggle()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Spacer()
                }

                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                
            }
            .alert("Delete Subscription?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    deleteSubscription()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete \(subscription.accountName)? This action cannot be undone.")
            }
                
        } else {
            DetailEmptyView()
        }
    }
    private func deleteSubscription() {
        if let subscription = subscription {
            modelContext.delete(subscription)
            try? modelContext.save()
        }
    }
}

