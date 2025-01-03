//
//  AddSubscriptionView.swift
//  Supscription
//
//  Created by Richie Flores on 1/3/25.
//

import SwiftUI

struct AddSubscriptionView: View {
    @Binding var isPresented: Bool
        @State private var accountName = ""
        @State private var description = ""
        @State private var price = ""

        var body: some View {
            VStack(spacing: 16) {
                Text("Add New Subscription")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Account Name")
                        .font(.headline)
                    TextField("Enter account name", text: $accountName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Description")
                        .font(.headline)
                    TextField("Enter description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Price")
                        .font(.headline)
                    TextField("Enter price", text: $price)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal, 20)

                HStack(spacing: 12) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 28)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .buttonStyle(PlainButtonStyle()) // Remove default button styling

                    Button("Save") {
                        saveSubscription()
                        isPresented = false
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 28)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .buttonStyle(PlainButtonStyle()) // Remove default button styling
                }
                .padding(.top, 16)
                
                Spacer()
            }
            .frame(maxWidth: 400)// Use clear to inherit system background
            .cornerRadius(16)
            .shadow(radius: 10)
            .padding()
        }
    
    private func saveSubscription() {
            // Placeholder for saving logic
            print("New subscription saved: \(accountName), \(description), \(price)")
        }
}

#Preview {
    AddSubscriptionView(isPresented: .constant(true))
}
