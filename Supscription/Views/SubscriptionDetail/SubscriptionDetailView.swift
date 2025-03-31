//
//  DetailView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI

struct SubscriptionDetailView: View {
    // parameters
    @Binding var selectedSubscription: Subscription?
    let allSubscriptions: [Subscription]
    
    @Environment(\.modelContext) var modelContext
    
    // manage state
    @State private var isEditing: Bool = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteOverlay: Bool = false
    
    var body: some View {
        ZStack {
            if let subscription = selectedSubscription {
                ScrollView {
                    VStack(spacing: 16) {
                        SubscriptionHeaderView(subscription: subscription)
                        
                        SubscriptionBillingInfoCard(subscription: subscription)
                        
                        if subscription.remindToCancel {
                            SubscriptionReminderCard(subscription: subscription)
                        }
                        
                        SubscriptionDetailsCard(subscription: subscription)
                        
                    }
                    .padding()
                }
                .sheet(isPresented: $isEditing) {
                    AddSubscriptionView(
                        isPresented: $isEditing,
                        isEditing: true,
                        subscriptionToEdit: subscription,
                        existingSubscriptions: allSubscriptions
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") {
                            isEditing.toggle()
                        }
                        .keyboardShortcut("e", modifiers: [.command])
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
                        .keyboardShortcut("d", modifiers: [.command])
                    }
                    
                }
                .alert("Delete Subscription?", isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        // 1. Show the overlay first
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            showDeleteOverlay = true
                        }
                        
                        // 2. Wait, then delete the subscription
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            deleteSubscription()
                        }
                        
                        // 3. Then fade out the overlay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showDeleteOverlay = false
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to delete \(subscription.accountName)? This action cannot be undone.")
                }
                
                
            } else {
                EmptySubscriptionDetailView()
            }
            if showDeleteOverlay {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 200, height: 150)
                        .shadow(radius: 10)
                        .scaleEffect(showDeleteOverlay ? 1 : 0.8)
                        .opacity(showDeleteOverlay ? 1 : 0)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "trash.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .foregroundStyle(.red)
                            .scaleEffect(showDeleteOverlay ? 1 : 0.8)
                            .opacity(showDeleteOverlay ? 1 : 0)
                        
                        Text("Subscription Deleted")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .opacity(showDeleteOverlay ? 1 : 0)
                    }
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showDeleteOverlay)
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
    }
    
    
    private func deleteSubscription() {
        if let subscription = selectedSubscription {
            modelContext.delete(subscription)
            try? modelContext.save()
            selectedSubscription = nil
        }
    }
}

