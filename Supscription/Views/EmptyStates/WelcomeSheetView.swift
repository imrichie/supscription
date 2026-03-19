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
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("BrandPurple"), Color("BrandPink")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
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
                    subtitle: "Stay on top of recurring payments with simple, manual tracking.",
                    iconColor: .blue
                )
                FeatureItem(
                    icon: "bell.badge",
                    title: "Get reminded before you’re billed",
                    subtitle: "Set alerts to cancel or review subscriptions before the next charge.",
                    iconColor: .orange
                )
                FeatureItem(
                    icon: "lock.shield",
                    title: "Private by design",
                    subtitle: "No accounts, no data scraping — your information stays on your device.",
                    iconColor: .green
                )
            }

            Spacer()

            // MARK: - Continue Button
            Button(action: {
                onDismiss()
            }) {
                Text("Start Tracking")
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
    var iconColor: Color = .secondary

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .light))
                .frame(width: 32)
                .foregroundColor(iconColor)

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
