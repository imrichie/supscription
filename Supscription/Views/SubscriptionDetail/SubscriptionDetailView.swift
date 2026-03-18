//
//  DetailView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI

struct SubscriptionDetailView: View {
    // MARK: - Bindings
    @Binding var selectedSubscription: Subscription?
    let allSubscriptions: [Subscription]
    let onDelete: (() -> Void)?

    // MARK: - Environments
    @Environment(\.modelContext) var modelContext

    // MARK: - State
    @State private var isEditing: Bool = false
    @State private var showDeleteConfirmation = false
    @State private var logoColor: Color? = nil

    // Shared CIContext — expensive to create, reuse across calls
    private static let ciContext = CIContext()

    // MARK: - View
    var body: some View {
        ZStack {
            if let subscription = selectedSubscription {
                ScrollView {
                    ZStack(alignment: .top) {

                        // Logo-derived gradient — scrolls with content, fades before the first card.
                        // Uses dominant color extracted from the logo; neutral gray when no logo.
                        LinearGradient(
                            colors: [(logoColor ?? Color(nsColor: .systemGray)).opacity(0.22), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: 0) {

                            // Zone 1 — Hero (no card)
                            SubscriptionHeaderView(subscription: subscription)
                                .padding(.bottom, 20)

                            // Zone 2 — Urgency banner (conditional)
                            if let days = daysUntilBilling(for: subscription), days <= 7 {
                                urgencyBanner(for: subscription, days: days)
                                    .padding(.bottom, 20)
                            }

                            // Separator — clear break between hero identity and card content
                            Divider()
                                .padding(.bottom, 24)

                            // Zone 3 — Billing
                            sectionLabel("Billing")
                            SubscriptionBillingInfoCard(subscription: subscription)
                                .padding(.bottom, 20)

                            // Zone 4 — Account
                            sectionLabel("Account")
                            SubscriptionDetailsCard(subscription: subscription)
                                .padding(.bottom, 20)

                            // Zone 5 — Reminders (always shown for discoverability)
                            sectionLabel("Reminders")
                            SubscriptionReminderCard(subscription: subscription)
                                .padding(.bottom, 20)

                            // Zone 6 — Actions (only when a website is set)
                            if let urlString = subscription.accountURL,
                               let url = URL(string: "https://\(urlString)") {
                                sectionLabel("Actions")
                                openWebsiteButton(url: url, domain: urlString)
                                    .padding(.bottom, 20)
                            }

                            // Zone 7 — Footer
                            Text("Last modified \(subscription.lastModified.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 12)
                        }
                        .frame(maxWidth: 550)
                        .padding(.horizontal, 48)
                        .padding(.top, 20)
                        .padding(.bottom, 32)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .background(Color(nsColor: .windowBackgroundColor))
                .frame(maxWidth: .infinity)
                .task(id: subscription.id) {
                    logoColor = await extractLogoColor(for: subscription)
                }
                .sheet(isPresented: $isEditing) {
                    AddSubscriptionView(
                        isPresented: $isEditing,
                        isEditing: true,
                        subscriptionToEdit: subscription,
                        existingSubscriptions: allSubscriptions
                    )
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") { isEditing.toggle() }
                            .keyboardShortcut("e", modifiers: [.command])
                    }
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .keyboardShortcut(.delete, modifiers: [.command])
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .editSubscription)) { _ in
                    isEditing = true
                }
                .onReceive(NotificationCenter.default.publisher(for: .deleteSubscription)) { _ in
                    showDeleteConfirmation = true
                }
                .alert(AppConstants.AppText.deleteConfirmationTitle, isPresented: $showDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            deleteSubscription()
                        }
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text(AppConstants.AppText.deleteConfirmationMessage(for: subscription.accountName))
                }
            } else {
                EmptyDetailView()
            }
        }
    }

    // MARK: - Section Label

    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .padding(.bottom, 6)
    }

    // MARK: - Open Website Button

    private func openWebsiteButton(url: URL, domain: String) -> some View {
        Link(destination: url) {
            HStack(spacing: 10) {
                Image(systemName: "safari")
                    .font(.system(size: 15, weight: .semibold))
                Text("Open \(domain)")
                    .font(.callout.weight(.semibold))
            }
            .foregroundStyle(Color.accentColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
    }

    // MARK: - Urgency Banner

    @ViewBuilder
    private func urgencyBanner(for subscription: Subscription, days: Int) -> some View {
        let color: Color = days < 1 ? .red : .orange
        let dateString = subscription.nextBillingDate
            .map { $0.formatted(date: .abbreviated, time: .omitted) } ?? ""
        let message: String = {
            switch days {
            case ..<0:  return "Payment overdue"
            case 0:     return "Due today — \(dateString)"
            case 1:     return "Due tomorrow — \(dateString)"
            default:    return "Due \(dateString) — in \(days) days"
            }
        }()

        HStack(spacing: 8) {
            Image(systemName: days < 1 ? "exclamationmark.circle.fill" : "calendar.badge.exclamationmark")
            Text(message)
        }
        .font(.callout.weight(.medium))
        .foregroundStyle(color)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(color.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(color.opacity(0.25), lineWidth: 0.5)
        )
    }

    // MARK: - Helpers

    private func daysUntilBilling(for subscription: Subscription) -> Int? {
        guard let date = subscription.nextBillingDate else { return nil }
        return Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: date)
        ).day
    }

    // MARK: - Logo Color Extraction

    /// Extracts the dominant color from a subscription's logo using CIAreaAverage.
    /// Runs on a background thread; returns nil if no logo is available.
    private func extractLogoColor(for subscription: Subscription) async -> Color? {
        guard let logoName = subscription.logoName, !logoName.isEmpty,
              let nsImage = loadLogoImage(named: logoName) else { return nil }

        return await Task.detached(priority: .userInitiated) {
            guard let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
            else { return nil }

            let ciImage = CIImage(cgImage: cgImage)
            guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
                kCIInputImageKey: ciImage,
                kCIInputExtentKey: CIVector(cgRect: ciImage.extent)
            ]), let output = filter.outputImage else { return nil }

            var pixel = [UInt8](repeating: 0, count: 4)
            await Self.ciContext.render(
                output,
                toBitmap: &pixel,
                rowBytes: 4,
                bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                format: .RGBA8,
                colorSpace: CGColorSpaceCreateDeviceRGB()
            )

            // Boost saturation so muted logo colors read clearly in the gradient
            var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            let raw = NSColor(
                red:   CGFloat(pixel[0]) / 255,
                green: CGFloat(pixel[1]) / 255,
                blue:  CGFloat(pixel[2]) / 255,
                alpha: 1
            )
            raw.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            let boosted = NSColor(
                hue:        h,
                saturation: min(s * 1.5, 1.0),
                brightness: max(b, 0.35),
                alpha:      1
            )
            return Color(nsColor: boosted)
        }.value
    }

    // MARK: - Delete

    private func deleteSubscription() {
        guard let subscription = selectedSubscription else { return }
        LogoFetchService.shared.deleteLogo(for: subscription)
        modelContext.delete(subscription)
        try? modelContext.save()
        selectedSubscription = nil
        onDelete?()
    }
}
