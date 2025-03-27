//
//  AddSubscriptionView.swift
//  Supscription
//
//  Created by Richie Flores on 1/3/25.
//

import SwiftUI

struct AddSubscriptionView: View {
    @Environment(\.modelContext) var modelContext
    @Binding var isPresented: Bool
    var onAdd: ((Subscription) -> Void)?
    
    var isEditing: Bool = false
    var subscriptionToEdit: Subscription?
    
    // Basic Info
    @State private var accountName: String = ""
    @State private var accountDescription: String = ""
    @State private var category: String = ""
    
    // Billing Info
    @State private var priceInput: String = ""
    @State private var price: Double? = nil
    @State private var billingDate: Date = Date()
    @State private var frequencySelection: String = "Monthly"
    @State private var billingFrequency: String = ""
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
                    TextField("Subscription", text: $accountName, prompt: Text("Name"))
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
                        ForEach(["Daily", "Weekly", "Monthly", "Quarterly", "Annually"], id: \.self) {
                            Text($0)
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
                frequencySelection = subscription.billingFrequency
                autoRenew = subscription.autoRenew
                remindToCancel = subscription.remindToCancel
                cancelReminderDate = subscription.cancelReminderDate ?? Date()
            }
        }
    }
    
    // MARK: - Helper functions
    // Validation and Conversion of Price logic
    private func validateAndConvertPrice(_ input: String) {
        if let value = Double(input), value >= 0 {
            price = value
        } else {
            price = nil
        }
    }
    
    private func isFormValid() -> Bool {
        !accountName.isEmpty && price != nil
    }
    
    // Save Subscriptoin Logic
    private func saveSubscription() {
        if isEditing, let subscription = subscriptionToEdit {
            // Update existing subscription instead of creating a new one
            subscription.accountName = accountName
            subscription.accountDescription = accountDescription
            subscription.category = category
            subscription.price = price ?? 0.0
            subscription.billingDate = billingDate
            subscription.billingFrequency = frequencySelection
            subscription.autoRenew = autoRenew
            subscription.remindToCancel = remindToCancel
            subscription.cancelReminderDate = cancelReminderDate
            
            try? modelContext.save() // Ensure changes are saved
        } else {
            // Create new subscription if not in edit mode
            let newSubscription = Subscription(
                accountName: accountName,
                accountDescription: accountDescription,
                category: category,
                price: price ?? 0.0,
                billingDate: billingDate,
                billingFrequency: frequencySelection,
                autoRenew: autoRenew,
                remindToCancel: remindToCancel,
                cancelReminderDate: cancelReminderDate
            )
            modelContext.insert(newSubscription)
            try? modelContext.save()
            onAdd?(newSubscription)
        }
    }
}
