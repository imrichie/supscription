//
//  AddSubscriptionView.swift
//  Supscription
//
//  Created by Richie Flores on 1/3/25.
//

import SwiftUI

struct AddSubscriptionView: View {
    @Binding var isPresented: Bool
    @State private var frequencySelection: String = "Select Frequency"
    
    // Basic Info
    @State private var accountName: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    
    // Billing Info
    @State private var priceInput: String = ""
    @State private var price: Double = 0.0
    @State private var billingDate: Date = Date()
    @State private var billingFrequency: String = ""
    @State private var autoRenew: Bool = false
    
    // Cancellation Info
    @State private var remindToCancel: Bool = false
    @State private var cancelReminderDate: Date = Date()
    
    let frequencies: [String] = ["Select Frequency", "Daily", "Weekly", "Monthly", "Quarterly", "6-Months", "Annually"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Add New Subscription")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
            
            Form {
                // Basic Info Section
                Section(header: Text("Basic Info")) {
                    TextField("Subscription Name", text: $accountName, prompt: Text("Name"))
                    TextField("Category", text: $category, prompt: Text("(e.g., Streaming, Work, School)"))
                }
                // Billing Info Section
                Section(header: Text("Billing Info")) {
                    TextField("Price", text: $priceInput, prompt: Text("$9.99"))
                        .onChange(of: priceInput) { oldValue, newValue in
                            validateAndConvertPrice(newValue)
                        }
                    DatePicker("Billing Date", selection: $billingDate, displayedComponents: .date)
                    Picker("Billing Frequency", selection: $frequencySelection) {
                        ForEach(frequencies, id: \.self) {
                            Text($0)
                        }
                        .pickerStyle(.menu)
                    }
                    // Toggle("Auto-Renew", isOn: $autoRenew)
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
            price = 0.0
        }
    }
    
    // Save Subscriptoin Logic
    private func saveSubscription() {
        // Placeholder for saving logic
        print("New subscription saved: \(accountName), \(description), \(price)")
    }
}

#Preview {
    AddSubscriptionView(isPresented: .constant(true))
}
