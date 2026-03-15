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

                        // Zone 1 — Hero (no card)
                        SubscriptionHeaderView(subscription: subscription)
                            .padding(.bottom, 20)

                        // Zone 2 — Urgency banner (conditional)
                        if let days = daysUntilBilling(for: subscription), days <= 7 {
                            urgencyBanner(for: subscription, days: days)
                                .padding(.bottom, 20)
                        }

                        // Separator — clear break between hero identity and card content
                        Divider()
                            .padding(.bottom, 24)

                        // Zone 3 — Billing
                        sectionLabel("Billing", icon: "creditcard.fill", color: .blue)
                        SubscriptionBillingInfoCard(subscription: subscription)
                            .padding(.bottom, 20)

                        // Zone 4 — Account
                        sectionLabel("Account", icon: "person.fill", color: .purple)
                        SubscriptionDetailsCard(subscription: subscription)
                            .padding(.bottom, 20)

                        // Zone 5 — Reminders (always shown for discoverability)
                        sectionLabel("Reminders", icon: "bell.fill", color: .orange)
                        SubscriptionReminderCard(subscription: subscription)
                            .padding(.bottom, 20)

                        // Zone 6 — Actions (only when a website is set)
                        if let urlString = subscription.accountURL,
                           let url = URL(string: "https://\(urlString)") {
                            sectionLabel("Actions", icon: "bolt.fill", color: .indigo)
                            openWebsiteButton(url: url, domain: urlString)
                                .padding(.bottom, 20)
                        }

                        // Zone 7 — Footer
                        Text("Last modified \(subscription.lastModified.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 12)
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
    // Small icon square + stepped-back text — icon does the expressive work

    private func sectionLabel(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(color)
                    .frame(width: 20, height: 20)
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
            }
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 6)
    }

    // MARK: - Open Website Button

    private func openWebsiteButton(url: URL, domain: String) -> some View {
        Link(destination: url) {
            HStack(spacing: 10) {
                Image(systemName: "safari")
                    .font(.system(size: 15, weight: .semibold))
                Text("Open \(domain)")
                    .font(.callout.weight(.semibold))
            }
            .foregroundStyle(Color.accentColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.accentColor.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.accentColor.opacity(0.2), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
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
