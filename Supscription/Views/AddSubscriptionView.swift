//
//  AddSubscriptionView.swift
//  Supscription
//
//  Created by Richie Flores on 1/3/25.
//

import SwiftUI

struct AddSubscriptionView: View {
    @Environment(\.modelContext) var modelContext
    
    // parameters
    @Binding var isPresented: Bool
    var existingSubscriptions: [Subscription] = []
    var onAdd: ((Subscription) -> Void)?
    
    var isEditing: Bool = false
    var subscriptionToEdit: Subscription?
    
    // Basic Info
    @State private var accountName: String = ""
    @State private var accountDescription: String = ""
    @State private var category: String = ""
    
    // Billing Info
    @State private var priceInput: String = "0.00"
    @State private var price: Double? = 0.00
    @State private var billingDate: Date = Date()
    @State private var frequencySelection: BillingFrequency = .monthly
    @State private var autoRenew: Bool = false
    
    // Cancellation Info
    @State private var remindToCancel: Bool = false
    @State private var cancelReminderDate: Date = Date()
    
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
                                .imageScale(.small)
                                .foregroundStyle(.secondary)
                            
                            Text("You already have a subscription named \(accountName)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                        .transition(.opacity)
                    }


                    
                    TextField("Description", text: $accountDescription, prompt: Text("Design Software"))
                    TextField("Category", text: $category, prompt: Text("e.g. Streaming, Productivity"))
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
                        ForEach(BillingFrequency.allCases) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        .pickerStyle(.menu)
                    }
                    Toggle("Is subscription on auto-renew?", isOn: $autoRenew)
                }
                
                // Cancellation Reminder Section
                Section(header: Text("Reminders")) {
                    Toggle("Set a reminder to cancel", isOn: $remindToCancel)
                    if remindToCancel {
                        DatePicker("Cancellation Date", selection: $cancelReminderDate, displayedComponents: .date)
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
                            isPresented = false
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
            if let subscription = subscriptionToEdit {
                accountName = subscription.accountName
                accountDescription = subscription.accountDescription ?? ""
                category = subscription.category ?? ""
                price = subscription.price
                billingDate = subscription.billingDate ?? Date()
                frequencySelection = BillingFrequency(rawValue: subscription.billingFrequency) ?? .monthly
                autoRenew = subscription.autoRenew
                remindToCancel = subscription.remindToCancel
                cancelReminderDate = subscription.cancelReminderDate ?? Date()
            }
        }
    }
    
    // MARK: - Helper functions
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
            // Update existing subscription instead of creating a new one
            subscription.accountName = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
            subscription.accountDescription = accountDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            subscription.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
            subscription.price = price ?? 0.0
            subscription.billingDate = billingDate
            subscription.billingFrequency = frequencySelection.rawValue
            subscription.autoRenew = autoRenew
            subscription.remindToCancel = remindToCancel
            subscription.cancelReminderDate = cancelReminderDate
            
            try? modelContext.save() // Ensure changes are saved
        } else {
            // Create new subscription if not in edit mode
            let newSubscription = Subscription(
                accountName: accountName.trimmingCharacters(in: .whitespacesAndNewlines),
                accountDescription: accountDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Uncategorized" : category.trimmingCharacters(in: .whitespacesAndNewlines),
                price: price ?? 0.0,
                billingDate: billingDate,
                billingFrequency: frequencySelection.rawValue,
                autoRenew: autoRenew,
                remindToCancel: remindToCancel,
                cancelReminderDate: cancelReminderDate
            )
            modelContext.insert(newSubscription)
            try? modelContext.save()
            onAdd?(newSubscription)
        }
    }
    
    private var isDuplicateName: Bool {
        let trimmedInput = accountName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        return existingSubscriptions.contains {
            $0.accountName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == trimmedInput &&
            (!isEditing || $0 != subscriptionToEdit)
        }
    }
}
