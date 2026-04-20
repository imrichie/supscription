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
    @Environment(\.dismiss) private var dismiss
    @Query private var allSubscriptions: [Subscription]

    let subscription: Subscription

    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false

    @State private var accountName = ""
    @State private var category = ""
    @State private var accountURL = ""
    @State private var priceInput = ""
    @State private var price: Double? = 0.0
    @State private var billingDate = Date()
    @State private var frequencySelection: BillingFrequency = .none
    @State private var autoRenew = false
    @State private var remindToCancel = false
    @State private var cancelReminderDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()

    private enum Field: Hashable {
        case name, category, website, price
    }

    @FocusState private var focusedField: Field?

    private var isDuplicateName: Bool {
        let trimmed = accountName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else { return false }

        return allSubscriptions.contains { existing in
            let existingName = existing.accountName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return existingName == trimmed && existing.id != subscription.id
        }
    }

    private var isFormValid: Bool {
        !accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && price != nil
    }

    var body: some View {
        List {
            if isEditing {
                editHeaderSection
                editableBillingSection
                editableAccountSection
                editableReminderSection
            } else {
                headerSection
                billingSection
                accountSection
                reminderSection
                deleteSection
            }
        }
        .navigationTitle(isEditing ? "Edit Subscription" : subscription.accountName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        cancelEditing()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!isFormValid)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            } else {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        beginEditing()
                    }
                }
            }
        }
        .onAppear(perform: loadDraftFromSubscription)
    }

    private var headerSection: some View {
        Section {
            HStack(spacing: 14) {
                subscriptionIcon

                VStack(alignment: .leading, spacing: 2) {
                    Text(subscription.accountName)
                        .font(.title3.weight(.semibold))
                        .frame(height: 28, alignment: .leading)

                    if let category = subscription.category,
                       !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(category)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(height: 22, alignment: .leading)
                    }
                }

                Spacer()

                Text(subscription.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.title3.weight(.semibold))
            }
            .padding(.vertical, 4)
        }
    }

    private var editHeaderSection: some View {
        Section {
            HStack(spacing: 14) {
                subscriptionIcon

                VStack(alignment: .leading, spacing: 2) {
                    TextField("Name", text: $accountName)
                        .font(.title3.weight(.semibold))
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .name)
                        .frame(height: 28, alignment: .leading)

                    TextField("Category", text: $category)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textFieldStyle(.plain)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .category)
                        .frame(height: 22, alignment: .leading)
                }

                Spacer()

                Text(price ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .padding(.vertical, 4)

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

    private var editableBillingSection: some View {
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

    private var accountSection: some View {
        Group {
            if let url = subscription.accountURL, !url.isEmpty {
                Section("Account") {
                    LabeledContent("Website", value: url)
                }
            }
        }
    }

    private var editableAccountSection: some View {
        Section("Account") {
            TextField("Website", text: $accountURL)
                .keyboardType(.URL)
                .textContentType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .website)
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

    private var editableReminderSection: some View {
        Section("Reminders") {
            Toggle("Remind to Cancel", isOn: $remindToCancel)
                .onChange(of: remindToCancel) { _, newValue in
                    guard newValue else { return }
                    Task { await NotificationService.shared.requestPermissionIfNeeded() }
                    if subscription.cancelReminderDate != nil { return }
                    setSmartReminderDate()
                }

            if remindToCancel {
                DatePicker("Reminder Date", selection: $cancelReminderDate, displayedComponents: .date)

                if frequencySelection != .none,
                   cancelReminderDate > frequencySelection.nextBillingDate(from: billingDate) {
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

    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Text("Delete Subscription")
                    Spacer()
                }
            }
        }
        .alert(
            "Delete \"\(subscription.accountName)\"?",
            isPresented: $showingDeleteConfirmation
        ) {
            Button("Delete", role: .destructive) {
                deleteSubscription()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func beginEditing() {
        loadDraftFromSubscription()
        isEditing = true
    }

    private func cancelEditing() {
        loadDraftFromSubscription()
        focusedField = nil
        isEditing = false
    }

    private func loadDraftFromSubscription() {
        accountName = subscription.accountName
        category = subscription.category ?? ""
        accountURL = subscription.accountURL ?? ""
        price = subscription.price
        priceInput = String(format: "%.2f", subscription.price)
        billingDate = subscription.billingDate ?? Date()
        frequencySelection = BillingFrequency(rawValue: subscription.billingFrequency) ?? .none
        autoRenew = subscription.autoRenew
        remindToCancel = subscription.remindToCancel
        cancelReminderDate = subscription.cancelReminderDate ?? (Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date())
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

    private func saveChanges() {
        let previousURL = subscription.accountURL

        subscription.accountName = accountName.capitalized.trimmingCharacters(in: .whitespacesAndNewlines)
        subscription.category = category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? nil
            : category.trimmingCharacters(in: .whitespacesAndNewlines)
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

        focusedField = nil
        isEditing = false
    }

    private func deleteSubscription() {
        NotificationService.shared.removeNotification(for: subscription)

        if subscription.logoName != nil {
            LogoFetchService.shared.deleteLogo(for: subscription)
        }
        modelContext.delete(subscription)
        try? modelContext.save()
        dismiss()
    }

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

#Preview {
    NavigationStack {
        SubscriptionDetailView(subscription: sampleSubscriptions[0])
    }
    .modelContainer(previewContainer)
}
