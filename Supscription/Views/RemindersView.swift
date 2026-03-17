//
//  RemindersView.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/16/26.
//

import SwiftUI
import SwiftData

struct RemindersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Subscription> { $0.remindToCancel == true })
    private var reminders: [Subscription]

    private var sortedReminders: [Subscription] {
        reminders.sorted { lhs, rhs in
            switch (lhs.cancelReminderDate, rhs.cancelReminderDate) {
            case let (l?, r?): return l < r
            case (_?, nil):    return true
            case (nil, _?):    return false
            case (nil, nil):   return lhs.accountName < rhs.accountName
            }
        }
    }

    var body: some View {
        Group {
            if sortedReminders.isEmpty {
                emptyState
            } else {
                remindersList
            }
        }
        .navigationTitle("Reminders")
    }

    // MARK: - List

    private var remindersList: some View {
        List {
            ForEach(sortedReminders) { subscription in
                HStack(spacing: 14) {
                    // Logo
                    logoView(for: subscription)

                    // Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(subscription.accountName)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)

                        Text(subscription.displayCategory)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Reminder date
                    if let reminderDate = subscription.cancelReminderDate {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Reminder set")
                                .font(.caption2)
                                .foregroundStyle(.secondary)

                            Text(reminderDate, format: .dateTime.month(.abbreviated).day().year())
                                .font(.caption.weight(.medium))
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        removeReminder(for: subscription)
                    } label: {
                        Label("Remove Reminder", systemImage: "bell.slash")
                    }
                }
                .contextMenu {
                    if let urlString = subscription.accountURL, !urlString.isEmpty {
                        Button("Open Website", systemImage: "safari") {
                            if let url = URL(string: urlString) {
                                NSWorkspace.shared.open(url)
                            }
                        }
                    }
                    Button("Remove Reminder", systemImage: "bell.slash", role: .destructive) {
                        removeReminder(for: subscription)
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No Reminders")
                .font(.title3.weight(.bold))

            Text("Subscriptions you flag to cancel will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Logo

    @ViewBuilder
    private func logoView(for subscription: Subscription) -> some View {
        ZStack {
            if let logoName = subscription.logoName, !logoName.isEmpty,
               let nsImage = loadLogoImage(named: logoName) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(0.15))
                Text(subscription.accountName.prefix(1).uppercased())
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(width: 34, height: 34)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color(.separatorColor), lineWidth: 0.5)
        )
    }

    // MARK: - Actions

    private func removeReminder(for subscription: Subscription) {
        subscription.remindToCancel = false
        subscription.cancelReminderDate = nil
        try? modelContext.save()
        NotificationService.shared.removeNotification(for: subscription)
    }
}
