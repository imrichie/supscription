//
//  ActionButtons.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/9/25.
//

import SwiftUI

struct ActionButtons: View {
    var body: some View {
        VStack {
            Button(action: {
                print("Edit Subscription Tapped")
            }) {
                Text("Edit Subscription")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button(action: {
                print("Delete Subscription Tapped")
            }) {
                Text("Delete Subscription")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.top, 4)
        }
    }
}
