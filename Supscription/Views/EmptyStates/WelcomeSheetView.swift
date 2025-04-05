//
//  WelcomeSheetView.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/4/25.
//

import SwiftUI

struct WelcomeSheetView: View {
    var onDismiss: () -> Void
    @State private var animate = false

    var body: some View {
        VStack(alignment: .center, spacing: 36) {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 16)
                    .animation(.easeOut(duration: 0.4), value: animate)
                
                // MARK: - Title & Subtitle
                VStack(alignment: .center, spacing: 4) {
                    Text("Welcome to Supscription")
                        .font(.system(size: 36, weight: .medium))
                        .multilineTextAlignment(.center)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 10)
                        .animation(.easeOut(duration: 0.5).delay(0.1), value: animate)
                    
                    Text("All your subscriptions, in one clean place.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : 10)
                        .animation(.easeOut(duration: 0.5).delay(0.15), value: animate)
                }
                .animation(.easeOut(duration: 0.5).delay(0.1), value: animate)
            }
            
            // MARK: - Features
            VStack(alignment: .leading, spacing: 32) {
                FeatureItem(
                    icon: "creditcard",
                    title: "Track subscriptions",
                    subtitle: "Keep an eye on recurring payments and never get surprised."
                )
                FeatureItem(
                    icon: "icloud",
                    title: "iCloud sync built in",
                    subtitle: "Your subscriptions are safely saved and synced."
                )
                FeatureItem(
                    icon: "chart.bar.xaxis",
                    title: "Visualize your spending",
                    subtitle: "View trends and breakdowns over time."
                )
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: animate)

            Spacer()

            // MARK: - Continue Button
            Button(action: {
                onDismiss()
            }) {
                Text("Continue")
                    .padding(.horizontal, 40)
                    .padding(.vertical, 8)
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.borderedProminent)
            .scaleEffect(animate ? 1 : 0.90)
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.3), value: animate)
        }
        .padding(40)
        .frame(minWidth: 700)
        .onAppear {
            animate = true
        }
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .light))
                .frame(width: 32)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}


#Preview {
    WelcomeSheetView(onDismiss: {})
}
