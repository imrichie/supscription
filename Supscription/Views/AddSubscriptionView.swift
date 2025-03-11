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
    
    init(isEditing: Bool = false, subscriptionToEdit: Subscription? = nil, isPresented: Binding<Bool>) {
        self.isEditing = isEditing
        self.subscriptionToEdit = subscriptionToEdit
        self._isPresented = isPresented
        
        // pre-fill the fields if editing an existing subscriptoin
        if let subscription = subscriptionToEdit {
            _accountName = State(initialValue: subscription.accountName)
            _accountDescription = State(initialValue: subscription.accountDescription)
            _category = State(initialValue: subscription.category)
            _price = State(initialValue: subscription.price)
            _billingDate = State(initialValue: subscription.billingDate ?? Date())
            _billingFrequency = State(initialValue: subscription.billingFrequency)
            _autoRenew = State(initialValue: subscription.autoRenew)
            _remindToCancel = State(initialValue: subscription.remindToCancel)
            _cancelReminderDate = State(initialValue: subscription.cancelReminderDate ?? Date())
        }
    }
    
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
                    TextField("Category", text: $category, prompt: Text("(e.g., Streaming, Work, School)"))
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
                }
                
                // Cancellation Reminder Section
                Section(header: Text("Reminders")) {
                    Toggle("Remind Me to Cancel", isOn: $remindToCancel)
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
        guard let validPrice = price else { return }
        
        let newSubscription = Subscription(
            accountName: accountName,
            accountDescription: accountDescription,
            category: category.isEmpty ? "Uncategorized" : category,
            price: validPrice,
            billingDate: billingDate,
            billingFrequency: frequencySelection,
            remindToCancel: remindToCancel,
            cancelReminderDate: remindToCancel ? cancelReminderDate : nil
        )
        
        modelContext.insert(newSubscription)
        
        // save the data
        do {
            try modelContext.save()
            print("Subscription saved successfully")
        } catch {
            print("Error saving subscription: \(error.localizedDescription)")
        }
    }
}
