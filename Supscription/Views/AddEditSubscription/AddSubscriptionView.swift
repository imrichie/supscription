//
//  AddSubscriptionView.swift
//  Supscription
//
//  Created by Richie Flores on 1/3/25.
//

import SwiftUI

struct AddSubscriptionView: View {
    // MARK: - Environment
    @Environment(\.modelContext) var modelContext
    
    // MARK: - Parameters
    @Binding var isPresented: Bool
    var isEditing: Bool = false
    var subscriptionToEdit: Subscription?
    var existingSubscriptions: [Subscription] = []
    var onAdd: ((Subscription) -> Void)?
    
    // MARK: - State (Basic Info)
    @State private var accountName: String = ""
    @State private var category: String = ""
    @State private var accountURL: String = ""
    
    // MARK: - State (Billing Info)
    @State private var priceInput: String = "0.00"
    @State private var price: Double? = 0.00
    @State private var billingDate: Date = Date()
    @State private var frequencySelection: BillingFrequency = .none
    @State private var autoRenew: Bool = false
    
    // MARK: - State (Cancellation Info)
    @State private var remindToCancel: Bool = false
    @State private var cancelReminderDate: Date = Date()
    
    // MARK: - Computed Properties
    private var isDuplicateName: Bool {
        let trimmedInput = accountName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return existingSubscriptions.contains { existing in
            let existingName = existing.accountName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let isSameName = existingName == trimmedInput
            let isSameItem = isEditing && existing.id == subscriptionToEdit?.id
            return isSameName && !isSameItem
        }
    }
    
    // MARK: - View
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text(isEditing ? "Edit \(accountName)" : "Add New Subscription")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
            
            Form {
                // Basic Info Section
                Section(header: Text("Account Info")) {
                    TextField("Subscription Name", text: $accountName, prompt: Text("Name"))
                        .onSubmit {
                            if isFormValid() {
                                saveSubscription()
                                isPresented = false
                            }
                        }


                    if isDuplicateName {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundStyle(.secondary)

                            Text("You already have a subscription named \(accountName)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    }
                    
                    TextField("Category", text: $category, prompt: Text("e.g. Streaming, Productivity"))
                    
                    TextField("Website", text: $accountURL, prompt: Text("example.com"))
                }

                
                // Billing Info Section
                Section(header: Text("Billing Info")) {
                    TextField("Price", text: $priceInput, prompt: Text("$9.99"))
                        .onChange(of: priceInput) { oldValue, newValue in
                            validateAndConvertPrice(newValue)
                        }
                    if price == nil && !priceInput.isEmpty {
                        Text("Please enter a valid price.")
                        .font(.caption)
                        .foregroundStyle(.red)
                    }
                    
                    DatePicker("Billing Date", selection: $billingDate, displayedComponents: .date)
                    
                    Picker("Billing Frequency", selection: $frequencySelection) {
                        ForEach(BillingFrequency.allCases) { freq in
                            Text(freq.rawValue.capitalized).tag(freq)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Toggle("Is subscription on auto-renew?", isOn: $autoRenew)
                        .onChange(of: remindToCancel) { oldValue, newValue in
                            if newValue {
                                Task {
                                    await NotificationService.shared.requestPermissionIfNeeded()
                                }
                            }
                        }
                }
                
                // Cancellation Reminder Section
                Section(header: Text("Reminders")) {
                    Toggle("Set a reminder to cancel", isOn: $remindToCancel)

                    if remindToCancel {
                        VStack(alignment: .leading, spacing: 4) {
                            DatePicker("Cancellation Date", selection: $cancelReminderDate, displayedComponents: .date)

                            if let frequency = BillingFrequency(rawValue: frequencySelection.rawValue),
                               cancelReminderDate > frequency.nextBillingDate(from: billingDate) {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundStyle(.secondary)

                                    Text("This reminder comes after the next billing date.")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .transition(.opacity)
                            }
                        }
                    }
                }
                
                // Action Buttons
                Section {
                    HStack {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .keyboardShortcut(.cancelAction)
                        Spacer()
                        Button("Save") {
                            saveSubscription()
                        }
                        .disabled(!isFormValid())
                        .keyboardShortcut(.defaultAction)
                    }
                }
            }
            .formStyle(.grouped)
        }
        .padding(.vertical)
        .onAppear {
            guard let subscription = subscriptionToEdit else { return }
            // basic info
            accountName = subscription.accountName
            category = subscription.category ?? ""
            accountURL = subscription.accountURL ?? ""
            
            // billing info
            price = subscription.price
            priceInput = String(format: "%.2f", subscription.price)
            billingDate = subscription.billingDate ?? Date()
            frequencySelection = BillingFrequency(rawValue: subscription.billingFrequency) ?? .none
            autoRenew = subscription.autoRenew
            
            // reminder info
            remindToCancel = subscription.remindToCancel
            cancelReminderDate = subscription.cancelReminderDate ?? Date()
        }
    }
    
    // MARK: - Private Methods
    
    // Validation and Conversion of Price logic
    private func validateAndConvertPrice(_ input: String) {
        if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            price = 0.0
        } else if let value = Double(input), value >= 0 {
            price = value
        } else {
            price = nil
        }
    }

    
    private func isFormValid() -> Bool {
        !accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Save Subscriptoin Logic
    private func saveSubscription() {
        if isEditing, let subscription = subscriptionToEdit {
            let previousURL = subscription.accountURL
            
            // Update existing subscription instead of creating a new one
            subscription.accountName = accountName.capitalized.trimmingCharacters(in: .whitespacesAndNewlines)
            subscription.accountURL = accountURL.isEmpty ? nil : accountURL
            subscription.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
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
            
            // If domain changed or no logo, reset logo and delete old
            resetLogoIfNeeded(for: subscription, didChangeURL: didChangeURL)
            
            try? modelContext.save()
            
            // Now re-fetch if needed
            if subscription.logoName == nil {
                Task {
                    await LogoFetchService.shared.fetchLogo(for: subscription, in: modelContext)
                }
            }
            
            if remindToCancel {
                NotificationService.shared.scheduleCancelReminder(for: subscription)
            } else {
                NotificationService.shared.removeNotification(for: subscription)
            }
        } else {
            // Create new subscription if not in edit mode
            let newSubscription = Subscription(
                accountName: accountName.capitalized.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Uncategorized" : category.trimmingCharacters(in: .whitespacesAndNewlines),
                price: price ?? 0.0,
                billingDate: billingDate,
                billingFrequency: frequencySelection.rawValue,
                autoRenew: autoRenew,
                remindToCancel: remindToCancel,
                cancelReminderDate: remindToCancel ? cancelReminderDate : nil,
                accountURL: accountURL.isEmpty ? nil : accountURL,
                lastModified: Date()
            )
            modelContext.insert(newSubscription)
            
            try? modelContext.save()
            
            onAdd?(newSubscription)
            Task {
                await LogoFetchService.shared.fetchLogo(for: newSubscription, in: modelContext)
            }
            
            if remindToCancel {
                NotificationService.shared.scheduleCancelReminder(for: newSubscription)
            }
        }
        isPresented = false
    }
    
    func resetLogoIfNeeded(for subscription: Subscription, didChangeURL: Bool) {
        if didChangeURL || (subscription.logoName?.isEmpty ?? true) {
            if subscription.logoName != nil {
                LogoFetchService.shared.deleteLogo(for: subscription)
            }
            subscription.logoName = nil
        }
    }
}
