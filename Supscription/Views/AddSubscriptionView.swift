//
//  AddSubscriptionView.swift
//  Supscription
//
//  Created by Richie Flores on 1/3/25.
//

import SwiftUI

struct AddSubscriptionView: View {
    @Binding var isPresented: Bool
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Basic Info Section
            Text("Basic Info")
                .font(.headline)
            TextField("Subscription Name", text: $accountName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Category (e.g., Streaming, Music, Work", text: $category)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Billing Info Section
            Text("Billing Info")
                .font(.headline)
            TextField("Price (e.g., 9.99", text: $priceInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: priceInput) { oldValue, newValue in
                    validateAndConvertPrice(newValue)
                }
            DatePicker("Billing Date", selection: $billingDate, displayedComponents: .date)
            Picker("Billing Freqency", selection: $billingFrequency) {
                Text("Monthly").tag("Monthly")
                Text("Yearly").tag("Yearly")
            }
            .pickerStyle(SegmentedPickerStyle())
            Toggle("Auto-Renew?", isOn: $autoRenew)
            
            // Cacellation Reminder Section
            Text("Cancellation Reminder")
                .font(.headline)
            Toggle("Remind to Cancel", isOn: $remindToCancel)
            if remindToCancel {
                DatePicker("Cancellation Date", selection: $cancelReminderDate, displayedComponents: .date)
            }
            
            // Action Buttons
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
                .disabled(accountName.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 10)
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
