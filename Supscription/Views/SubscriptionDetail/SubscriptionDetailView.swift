//
//  DetailView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI

struct SubscriptionDetailView: View {
    // MARK: - Bindings
    @Binding var selectedSubscription: Subscription?
    let allSubscriptions: [Subscription]
    let onDelete: (() -> Void)?
    
    // MARK: - Environments
    @Environment(\.modelContext) var modelContext
    
    // MARK: - State
    @State private var isEditing: Bool = false
    @State private var showDeleteConfirmation = false
    @State private var showDeleteOverlay: Bool = false
    
    // MARK: - View
    var body: some View {
        ZStack {
            if let subscription = selectedSubscription {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        SubscriptionHeaderView(subscription: subscription)
                        
                        Text("Billing Info")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 20)
                        SubscriptionBillingInfoCard(subscription: subscription)
                        
                        if subscription.remindToCancel {
                            Text("Reminder")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.top, 24)
                            SubscriptionReminderCard(subscription: subscription)
                        }
                        Text("Details")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.top, 24)
                        SubscriptionDetailsCard(subscription: subscription)
                    }
                    .frame(maxWidth: 550)
                    .padding(.horizontal, 48)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity)
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
                .onReceive(NotificationCenter.default.publisher(for: .editSubscription)) { _ in
                    isEditing = true
                }
                .onReceive(NotificationCenter.default.publisher(for: .deleteSubscription)) { _ in
                    showDeleteConfirmation = true
                }
                .alert(AppConstants.AppText.deleteConfirmationTitle, isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        // 1. Show the overlay first
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        }
                        
                        // 2. Wait, then delete the subscription
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            deleteSubscription()
                        }
                        
                        // 3. Then fade out the overlay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                            }
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text(AppConstants.AppText.deleteConfirmationMessage(for: subscription.accountName))
                }
            } else {
                EmptyDetailView()
            }
        }
    }
    
    // MARK: - Private Methods
    private func deleteSubscription() {
        if let subscription = selectedSubscription {
            // Delete logo image file first
            LogoFetchService.shared.deleteLogo(for: subscription)
            
            // Then delete from model
            modelContext.delete(subscription)
            try? modelContext.save()
            
            // clear selected state
            selectedSubscription = nil
            onDelete?()
        }
    }
}
