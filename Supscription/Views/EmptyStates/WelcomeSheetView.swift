//
//  WelcomeSheetView.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/4/25.
//

import SwiftUI

struct WelcomeSheetView: View {
    var onDismiss: () -> Void

    var body: some View {        
        VStack(alignment: .center, spacing: 36) {
            VStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                // MARK: - Title & Subtitle
                VStack(alignment: .center, spacing: 4) {
                    Text("Welcome to Supscription")
                        .font(.system(size: 36, weight: .medium))
                        .multilineTextAlignment(.center)
                    
                    Text("All your subscriptions, in one clean place.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // MARK: - Features
            VStack(alignment: .leading, spacing: 32) {
                FeatureItem(
                    icon: "creditcard",
                    title: "Track subscriptions",
                    subtitle: "Stay on top of recurring payments with simple, manual tracking."
                )
                FeatureItem(
                    icon: "bell.badge",
                    title: "Get reminded before you’re billed",
                    subtitle: "Set alerts to cancel or review subscriptions before the next charge."
                )
                FeatureItem(
                    icon: "lock.shield",
                    title: "Private by design",
                    subtitle: "No accounts, no data scraping — your information stays on your device."
                )
            }

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
        }
        .padding(40)
        .frame(minWidth: 800)
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
