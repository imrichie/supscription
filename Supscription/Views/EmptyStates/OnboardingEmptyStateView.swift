//
//  OnboardingEmptyStateView.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/2/25.
//

import SwiftUI

struct OnboardingEmptyStateView: View {
    var onAddSubscription: () -> Void
    //@Binding var isAddingSubscription: Bool
    @State private var appear = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "rectangle.stack.fill.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.secondary)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.1), value: appear)
                
                VStack(spacing: 8) {
                    Text("Let’s add your first subscription")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    
                    Text("To start tracking your subscriptions, click the button below or use the + in the toolbar.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: appear)
                
                Button(action: {
                    onAddSubscription()
                }) {
                    Label("Add Subscription", systemImage: "plus")
                        .padding(8)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 24)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: appear)
            }
            
            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            appear = true
        }
    }
}

#Preview {
    OnboardingEmptyStateView(onAddSubscription: {})
}
