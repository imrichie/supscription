//
//  OnboardingEmptyStateView.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/2/25.
//

import SwiftUI

struct OnboardingEmptyStateView: View {
    @Binding var isAddingSubscription: Bool
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

                    VStack(spacing: 4) {
                        Text("👋 Track your subscriptions with ease")
                            .font(.largeTitle)
                            .fontWeight(.semibold)

                        Text("Start by adding your first one to see how it works")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.2), value: appear)

                    Button(action: {
                        isAddingSubscription = true
                    }) {
                        Label("Add Subscription", systemImage: "plus")
                            .padding(8)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
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
    OnboardingEmptyStateView(isAddingSubscription: .constant(false))
}
