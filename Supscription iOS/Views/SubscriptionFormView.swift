//
//  SubscriptionFormView.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/9/26.
//

import SwiftUI
import SwiftData

struct SubscriptionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - Parameters
    var subscriptionToEdit: Subscription?
    var existingSubscriptions: [Subscription] = []

    private var isEditing: Bool { subscriptionToEdit != nil }

    // MARK: - State (Account Info)
    @State private var accountName = ""
    @State private var category = ""
    @State private var accountURL = ""

    // MARK: - State (Billing Info)
    @State private var priceInput = ""
    @State private var price: Double? = 0.0
    @State private var billingDate = Date()
    @State private var frequencySelection: BillingFrequency = .none
    @State private var autoRenew = false

    // MARK: - State (Reminders)
    @State private var remindToCancel = false
    @State private var cancelReminderDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()

    // MARK: - AI Availability
    private static var supportsOnDeviceAI: Bool {
        if #available(macOS 26, iOS 26, *) { return true }
        return false
    }

    // MARK: - Computed Properties
    private var isDuplicateName: Bool {
        let trimmed = accountName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return false }

        return existingSubscriptions.contains { existing in
            let existingName = existing.accountName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let isSameName = existingName == trimmed
            let isSameItem = isEditing && existing.id == subscriptionToEdit?.id
            return isSameName && !isSameItem
        }
    }

    private var isFormValid: Bool {
        !accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && price != nil
    }

    private enum Field: Hashable {
        case name, category, website, price
    }

    @FocusState private var focusedField: Field?

    // MARK: - View
    var body: some View {
        NavigationStack {
            Form {
                headerSection
                billingInfoSection
                accountSection
                remindersSection
            }
            .navigationTitle(isEditing ? "Edit Subscription" : "New Subscription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isFormValid)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
        }
        .onAppear(perform: populateFieldsIfEditing)
    }

    // MARK: - Sections

    private var headerSection: some View {
        Section {
            SubscriptionIdentityHeaderView(
                logoName: nil,
                fallbackName: accountName
            ) {
                TextField("Name", text: $accountName)
                    .font(.title3.weight(.semibold))
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .name)
            } categoryContent: {
                TextField("Category", text: $category)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .category)
            } trailingContent: {
                Text(price ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            if isDuplicateName {
                Label(
                    "You already have a subscription named \"\(accountName)\"",
                    systemImage: "exclamationmark.circle"
                )
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var accountSection: some View {
        Section("Account") {
            TextField("Website", text: $accountURL)
                .keyboardType(.URL)
                .textContentType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .website)
        }
    }

    private var billingInfoSection: some View {
        Section("Billing") {
            LabeledContent("Price") {
                HStack(spacing: 6) {
                    Text(Locale.current.currencySymbol ?? "$")
                        .foregroundStyle(.secondary)

                    TextField("0.00", text: $priceInput)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .focused($focusedField, equals: .price)
                        .onChange(of: priceInput) { _, newValue in
                            validatePrice(newValue)
                        }
                }
                .frame(minWidth: 90)
            }

            if price == nil && !priceInput.isEmpty {
                Text("Please enter a valid price.")
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            DatePicker("Billing Date", selection: $billingDate, displayedComponents: .date)

            Picker("Frequency", selection: $frequencySelection) {
                ForEach(BillingFrequency.allCases) { freq in
                    Text(freq.rawValue).tag(freq)
                }
            }

            Toggle("Auto-Renew", isOn: $autoRenew)
        }
    }

    private var remindersSection: some View {
        Section("Reminders") {
            Toggle("Remind to Cancel", isOn: $remindToCancel)
                .onChange(of: remindToCancel) { _, newValue in
                    guard newValue else { return }
                    Task { await NotificationService.shared.requestPermissionIfNeeded() }
                    if isEditing, subscriptionToEdit?.cancelReminderDate != nil { return }
                    setSmartReminderDate()
                }

            if remindToCancel {
                DatePicker("Reminder Date", selection: $cancelReminderDate, displayedComponents: .date)

                if let frequency = BillingFrequency(rawValue: frequencySelection.rawValue),
                   frequency != .none,
                   cancelReminderDate > frequency.nextBillingDate(from: billingDate) {
                    Label(
                        "This reminder comes after the next billing date.",
                        systemImage: "exclamationmark.circle"
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func populateFieldsIfEditing() {
        guard let subscription = subscriptionToEdit else { return }

        accountName = subscription.accountName
        category = subscription.category ?? ""
        accountURL = subscription.accountURL ?? ""

        price = subscription.price
        priceInput = String(format: "%.2f", subscription.price)
        billingDate = subscription.billingDate ?? Date()
        frequencySelection = BillingFrequency(rawValue: subscription.billingFrequency) ?? .none
        autoRenew = subscription.autoRenew

        remindToCancel = subscription.remindToCancel
        cancelReminderDate = subscription.cancelReminderDate ?? Date()
    }

    private func validatePrice(_ input: String) {
        if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            price = 0.0
        } else if let value = Double(input), value >= 0 {
            price = value
        } else {
            price = nil
        }
    }

    private func setSmartReminderDate() {
        let calendar = Calendar.current
        if frequencySelection != .none {
            let nextBilling = frequencySelection.nextBillingDate(from: billingDate)
            if let smartDate = calendar.date(byAdding: .day, value: -3, to: nextBilling),
               smartDate > Date() {
                cancelReminderDate = smartDate
            } else {
                cancelReminderDate = calendar.date(byAdding: .day, value: 30, to: Date()) ?? Date()
            }
        } else {
            cancelReminderDate = calendar.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        }
    }

    private func save() {
        if isEditing, let subscription = subscriptionToEdit {
            updateExisting(subscription)
        } else {
            createNew()
        }
        dismiss()
    }

    private func updateExisting(_ subscription: Subscription) {
        let previousURL = subscription.accountURL

        subscription.accountName = accountName.capitalized.trimmingCharacters(in: .whitespacesAndNewlines)
        subscription.category = category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? nil : category.trimmingCharacters(in: .whitespacesAndNewlines)
        subscription.price = price ?? 0.0
        subscription.billingDate = billingDate
        subscription.billingFrequency = frequencySelection.rawValue
        subscription.autoRenew = autoRenew
        subscription.remindToCancel = remindToCancel
        subscription.cancelReminderDate = remindToCancel ? cancelReminderDate : nil
        subscription.lastModified = Date()

        let newURL = accountURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let didChangeURL = previousURL != newURL
        subscription.accountURL = newURL.isEmpty ? nil : newURL

        if didChangeURL || (subscription.logoName?.isEmpty ?? true) {
            if subscription.logoName != nil {
                LogoFetchService.shared.deleteLogo(for: subscription)
            }
            subscription.logoName = nil
        }

        try? modelContext.save()

        // Handle notifications
        if remindToCancel {
            NotificationService.shared.scheduleCancelReminder(for: subscription)
        } else {
            NotificationService.shared.removeNotification(for: subscription)
        }

        if subscription.logoName == nil {
            Task {
                await LogoFetchService.shared.fetchLogo(for: subscription, in: modelContext)
            }
        }
    }

    private func createNew() {
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = accountURL.trimmingCharacters(in: .whitespacesAndNewlines)

        let newSubscription = Subscription(
            accountName: accountName.capitalized.trimmingCharacters(in: .whitespacesAndNewlines),
            category: trimmedCategory.isEmpty ? "Uncategorized" : trimmedCategory,
            price: price ?? 0.0,
            billingDate: billingDate,
            billingFrequency: frequencySelection.rawValue,
            autoRenew: autoRenew,
            remindToCancel: remindToCancel,
            cancelReminderDate: remindToCancel ? cancelReminderDate : nil,
            accountURL: trimmedURL.isEmpty ? nil : trimmedURL,
            lastModified: Date()
        )

        modelContext.insert(newSubscription)
        try? modelContext.save()

        // Handle notifications
        if remindToCancel {
            NotificationService.shared.scheduleCancelReminder(for: newSubscription)
        }

        Task {
            await LogoFetchService.shared.fetchLogo(for: newSubscription, in: modelContext)
        }

        if Self.supportsOnDeviceAI && (newSubscription.category == nil || newSubscription.category == "Uncategorized") {
            let context = modelContext
            let name = newSubscription.accountName
            let existingCats = existingSubscriptions.compactMap { $0.category }
            Task.detached {
                if let suggested = await CategorySuggestionService.shared.suggest(
                    for: name,
                    existingCategories: existingCats
                ) {
                    await MainActor.run {
                        newSubscription.category = suggested
                        newSubscription.lastModified = Date()
                        try? context.save()
                    }
                }
            }
        }
    }
}

#Preview("Add") {
    SubscriptionFormView()
        .modelContainer(previewContainer)
}

#Preview("Edit") {
    SubscriptionFormView(
        subscriptionToEdit: sampleSubscriptions.first!
    )
    .modelContainer(previewContainer)
}
