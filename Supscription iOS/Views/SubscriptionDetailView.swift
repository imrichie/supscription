//
//  SubscriptionDetailView.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/9/26.
//

import SwiftUI
import SwiftData

struct SubscriptionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allSubscriptions: [Subscription]

    let subscription: Subscription
    @State private var showingEditSheet = false

    var body: some View {
        List {
            headerSection
            billingSection
            accountSection
            reminderSection
        }
        .navigationTitle(subscription.accountName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .fullScreenCover(isPresented: $showingEditSheet) {
            SubscriptionFormView(
                subscriptionToEdit: subscription,
                existingSubscriptions: allSubscriptions
            )
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        Section {
            HStack(spacing: 14) {
                subscriptionIcon
                VStack(alignment: .leading, spacing: 2) {
                    Text(subscription.accountName)
                        .font(.title3.weight(.semibold))
                    if let category = subscription.category, !category.isEmpty {
                        Text(category)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(subscription.price, format: .currency(code: "USD"))
                    .font(.title3.weight(.semibold))
            }
            .padding(.vertical, 4)
        }
    }

    private var billingSection: some View {
        Section("Billing") {
            LabeledContent("Frequency", value: subscription.billingFrequency)

            if let billingDate = subscription.billingDate {
                LabeledContent("Billing Date") {
                    Text(billingDate, style: .date)
                }
            }

            if let nextDate = subscription.nextBillingDate {
                LabeledContent("Next Billing") {
                    Text(nextDate, style: .date)
                }
            }

            LabeledContent("Auto-Renew") {
                Image(systemName: subscription.autoRenew ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(subscription.autoRenew ? .green : .secondary)
            }
        }
    }

    private var accountSection: some View {
        Group {
            if let url = subscription.accountURL, !url.isEmpty {
                Section("Account") {
                    LabeledContent("Website", value: url)
                }
            }
        }
    }

    private var reminderSection: some View {
        Group {
            if subscription.remindToCancel {
                Section("Reminders") {
                    LabeledContent("Cancel Reminder") {
                        if let date = subscription.cancelReminderDate {
                            Text(date, style: .date)
                        } else {
                            Text("Not set")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private var subscriptionIcon: some View {
        if let logoName = subscription.logoName, !logoName.isEmpty,
           let uiImage = loadLogoImage(named: logoName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Image(systemName: "app.fill")
                .font(.title)
                .foregroundStyle(.secondary)
                .frame(width: 40, height: 40)
        }
    }

    private func loadLogoImage(named logoName: String) -> UIImage? {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let logoPath = supportDir
            .appendingPathComponent("Logos", isDirectory: true)
            .appendingPathComponent("\(logoName).png")

        guard let data = try? Data(contentsOf: logoPath) else { return nil }
        return UIImage(data: data)
    }
}
