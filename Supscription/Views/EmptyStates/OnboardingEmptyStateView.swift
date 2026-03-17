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
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color(.controlBackgroundColor))
                        .frame(width: 120, height: 120)

                    Image(systemName: "rectangle.stack.fill.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 56, height: 56)
                        .foregroundStyle(.secondary)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.1), value: appear)

                VStack(spacing: 8) {
                    Text("Your subscriptions will live here.\nLet’s add the first one.")
                        .font(.title2.weight(.semibold))
                        .multilineTextAlignment(.center)
                }
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.2), value: appear)
                
                Button(action: {
                    onAddSubscription()
                }) {
                    Label("Add Subscription", systemImage: "plus")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(Color.accentColor))
                }
                .buttonStyle(.plain)
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
