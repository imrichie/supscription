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

    @State private var subscriptionToDelete: Subscription?
    @State private var confirmDelete: Bool = false

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

    // MARK: - Monthly Savings

    private func monthlyEquivalent(_ sub: Subscription) -> Double {
        guard let frequency = BillingFrequency(rawValue: sub.billingFrequency) else { return 0 }
        switch frequency {
        case .daily:      return sub.price * 30.44
        case .weekly:     return sub.price * 4.33
        case .monthly:    return sub.price
        case .quarterly:  return sub.price / 3
        case .yearly:     return sub.price / 12
        case .none:       return 0
        }
    }

    private var potentialMonthlySavings: Double {
        reminders.reduce(0) { $0 + monthlyEquivalent($1) }
    }

    private var formattedSavings: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: potentialMonthlySavings)) ?? "$0.00"
    }

    // MARK: - Urgency

    private func daysUntilReminder(_ date: Date?) -> Int? {
        guard let date else { return nil }
        return Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        ).day
    }

    // MARK: - Body

    var body: some View {
        Group {
            if sortedReminders.isEmpty {
                emptyState
            } else {
                reminderContent
            }
        }
        .confirmationDialog(
            "Delete \(subscriptionToDelete?.accountName ?? "")?",
            isPresented: $confirmDelete,
            presenting: subscriptionToDelete
        ) { subscription in
            Button("Delete", role: .destructive) {
                modelContext.delete(subscription)
                try? modelContext.save()
            }
            Button("Cancel", role: .cancel) {}
        } message: { subscription in
            Text("This will permanently delete \(subscription.accountName) from Supscription. This cannot be undone.")
        }
    }

    // MARK: - Content

    private var reminderContent: some View {
        ScrollView {
            cardsList
                .padding(28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var savingsBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "leaf.fill")
                .font(.caption2)

            Text("Save \(formattedSavings)/mo")
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(Color.green)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.green.opacity(0.1))
        )
    }

    // MARK: - Cards List

    private var cardsList: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 300, maximum: 420), spacing: 14)],
            spacing: 14
        ) {
            Section {
                ForEach(sortedReminders) { subscription in
                    reminderCard(for: subscription)
                }
            } header: {
                savingsBadge
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)
            }
        }
    }

    // MARK: - Card

    private func reminderCard(for subscription: Subscription) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card content
            VStack(alignment: .leading, spacing: 14) {
                // Top row: logo, name, price
                HStack(spacing: 14) {
                    logoView(for: subscription)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(subscription.accountName)
                            .font(.headline)
                            .lineLimit(1)

                        let freq = BillingFrequency(rawValue: subscription.billingFrequency)?.rawValue ?? ""
                        let detail = [subscription.displayCategory, freq]
                            .filter { !$0.isEmpty }
                            .joined(separator: " \u{00B7} ")
                        Text(detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(subscription.formattedPrice)
                            .font(.title3.weight(.bold))

                        urgencyBadge(for: subscription)
                    }
                }
            }
            .padding(16)

            Divider()
                .padding(.horizontal, 16)

            // Actions
            VStack(spacing: 0) {
                // Primary: I've Cancelled This
                Button {
                    subscriptionToDelete = subscription
                    confirmDelete = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("I've Cancelled This")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.accentColor.opacity(0.12))
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.top, 12)

                // Secondary: Open website
                if let urlString = subscription.accountURL, !urlString.isEmpty {
                    Button {
                        if let url = URL(string: urlString) {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.right")
                                .font(.caption2.weight(.semibold))
                            Text("Open website to cancel")
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
            }
            .padding(.bottom, 14)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separatorColor), lineWidth: 0.5)
        )
    }

    // MARK: - Urgency Badge

    @ViewBuilder
    private func urgencyBadge(for subscription: Subscription) -> some View {
        let days = daysUntilReminder(subscription.cancelReminderDate)

        if let days {
            let (label, bg, fg): (String, Color, Color) = {
                switch days {
                case ...0:
                    return ("Overdue", Color.red.opacity(0.12), .red)
                case 1...7:
                    return ("Due in \(days)d", Color.orange.opacity(0.12), .orange)
                default:
                    let formatted = subscription.cancelReminderDate!
                        .formatted(.dateTime.month(.abbreviated).day())
                    return (formatted, Color(.secondaryLabelColor).opacity(0.12), .secondary)
                }
            }()

            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(fg)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(bg))
        }
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
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor.opacity(0.15))
                Text(subscription.accountName.prefix(1).uppercased())
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(width: 48, height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.separatorColor), lineWidth: 0.5)
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bell.slash")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text("Nothing to cancel")
                .font(.title3.weight(.bold))

            Text("Subscriptions you flag to cancel will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 260)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
