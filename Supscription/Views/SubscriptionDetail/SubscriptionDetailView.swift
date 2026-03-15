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

    // MARK: - View
    var body: some View {
        ZStack {
            if let subscription = selectedSubscription {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        // Zone 1 — Hero header (no card)
                        SubscriptionHeaderView(subscription: subscription)
                            .padding(.bottom, 20)

                        // Zone 2 — Urgency banner (conditional: due within 7 days)
                        if let days = daysUntilBilling(for: subscription), days <= 7 {
                            urgencyBanner(for: subscription, days: days)
                                .padding(.bottom, 20)
                        }

                        // Zone 3 — Billing section
                        sectionLabel("Billing", icon: "creditcard.fill", color: .blue)
                        SubscriptionBillingInfoCard(subscription: subscription)
                            .padding(.bottom, 20)

                        // Zone 4 — Account section
                        sectionLabel("Account", icon: "info.circle.fill", color: .purple)
                        SubscriptionDetailsCard(subscription: subscription)

                        // Zone 5 — Footer metadata
                        Text("Last modified \(subscription.lastModified.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 32)
                    }
                    .frame(maxWidth: 550)
                    .padding(.horizontal, 48)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
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
                        Button("Edit") { isEditing.toggle() }
                            .keyboardShortcut("e", modifiers: [.command])
                    }
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .keyboardShortcut(.delete, modifiers: [.command])
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            deleteSubscription()
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

    // MARK: - Section Label

    private func sectionLabel(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(color)
                    .frame(width: 22, height: 22)
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.bottom, 6)
    }

    // MARK: - Urgency Banner

    @ViewBuilder
    private func urgencyBanner(for subscription: Subscription, days: Int) -> some View {
        let color: Color = days < 1 ? .red : .orange
        let dateString = subscription.nextBillingDate
            .map { $0.formatted(date: .abbreviated, time: .omitted) } ?? ""
        let message: String = {
            switch days {
            case ..<0:  return "Payment overdue"
            case 0:     return "Due today — \(dateString)"
            case 1:     return "Due tomorrow — \(dateString)"
            default:    return "Due \(dateString) — in \(days) days"
            }
        }()

        HStack(spacing: 8) {
            Image(systemName: days < 1 ? "exclamationmark.circle.fill" : "calendar.badge.exclamationmark")
            Text(message)
        }
        .font(.callout.weight(.medium))
        .foregroundStyle(color)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 0.5)
        )
    }

    // MARK: - Helpers

    private func daysUntilBilling(for subscription: Subscription) -> Int? {
        guard let date = subscription.nextBillingDate else { return nil }
        return Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        ).day
    }

    // MARK: - Delete

    private func deleteSubscription() {
        guard let subscription = selectedSubscription else { return }
        LogoFetchService.shared.deleteLogo(for: subscription)
        modelContext.delete(subscription)
        try? modelContext.save()
        selectedSubscription = nil
        onDelete?()
    }
}
