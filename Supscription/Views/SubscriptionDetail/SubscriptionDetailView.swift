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
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - State
    @State private var isEditing: Bool = false
    @State private var showDeleteConfirmation = false
    @State private var logoColor: Color? = nil

    // MARK: - Edit State
    @State private var editName: String = ""
    @State private var editCategory: String = ""
    @State private var editURL: String = ""
    @State private var editPriceInput: String = "0.00"
    @State private var editPrice: Double? = 0.00
    @State private var editBillingDate: Date = Date()
    @State private var editFrequency: BillingFrequency = .none
    @State private var editAutoRenew: Bool = false
    @State private var editRemindToCancel: Bool = false
    @State private var editReminderDate: Date = Date()

    // MARK: - Focus
    enum EditField: Hashable {
        case name, category, website, price
    }
    @FocusState private var focusedField: EditField?

    // Shared CIContext — expensive to create, reuse across calls
    private static let ciContext = CIContext()

    // MARK: - Computed

    private var isEditFormValid: Bool {
        !editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isDuplicateName: Bool {
        let trimmed = editName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return allSubscriptions.contains { existing in
            let existingName = existing.accountName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return existingName == trimmed && existing.id != selectedSubscription?.id
        }
    }

    // MARK: - View
    var body: some View {
        ZStack {
            if let subscription = selectedSubscription {
                ScrollView {
                    ZStack(alignment: .top) {

                        // Blurred logo background — immersive header with scrim
                        Group {
                            if let logoName = subscription.logoName, !logoName.isEmpty,
                               let nsImage = loadLogoImage(named: logoName) {
                                ZStack {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .scaledToFill()
                                        .blur(radius: 82)
                                        .scaleEffect(1.3) // prevent blur edge artifacts
                                        .clipped()

                                    // Scrim for text readability
                                    (colorScheme == .dark
                                        ? Color.black.opacity(0.72)
                                        : Color.white.opacity(0.78))
                                }
                            } else {
                                Color(.windowBackgroundColor)
                            }
                        }
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .mask(
                            LinearGradient(
                                colors: [.black, .black, .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                        VStack(alignment: .leading, spacing: 0) {

                            // Zone 1 — Hero
                            if isEditing {
                                editableHeader(subscription: subscription)
                                    .padding(.bottom, 20)
                            } else {
                                SubscriptionHeaderView(subscription: subscription)
                                    .padding(.bottom, 20)
                            }

                            // Zone 2 — Urgency banner (read mode only)
                            if !isEditing, let days = daysUntilBilling(for: subscription), days <= 7 {
                                urgencyBanner(for: subscription, days: days)
                                    .padding(.bottom, 20)
                            }

                            // Separator
                            Divider()
                                .padding(.bottom, 24)

                            // Zone 3 — Billing
                            sectionLabel("Billing")
                            if isEditing {
                                editableBillingCard
                                    .padding(.bottom, 20)
                            } else {
                                SubscriptionBillingInfoCard(subscription: subscription)
                                    .padding(.bottom, 20)
                            }

                            // Zone 4 — Account
                            sectionLabel("Account")
                            if isEditing {
                                editableAccountCard
                                    .padding(.bottom, 20)
                            } else {
                                SubscriptionDetailsCard(subscription: subscription)
                                    .padding(.bottom, 20)
                            }

                            // Zone 5 — Reminders
                            sectionLabel("Reminders")
                            if isEditing {
                                editableReminderCard
                                    .padding(.bottom, 20)
                            } else {
                                SubscriptionReminderCard(subscription: subscription)
                                    .padding(.bottom, 20)
                            }

                            // Zone 6 — Actions (read mode only)
                            if !isEditing,
                               let urlString = subscription.accountURL,
                               !urlString.isEmpty {
                                let fullURL = urlString.hasPrefix("http") ? urlString : "https://\(urlString)"
                                if let url = URL(string: fullURL) {
                                    openWebsiteButton(url: url, domain: urlString)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 8)
                                }
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
                .toolbar {
                    if isEditing {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isEditing = false
                            }
                            .keyboardShortcut(.cancelAction)
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                saveEdits()
                                isEditing = false
                            }
                            .disabled(!isEditFormValid)
                            .keyboardShortcut(.defaultAction)
                            .tint(.blue)
                        }
                    } else {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Edit") {
                                populateEditFields()
                                isEditing = true
                            }
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
                }
                .onReceive(NotificationCenter.default.publisher(for: .editSubscription)) { _ in
                    populateEditFields()
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
                .onChange(of: selectedSubscription) { _, _ in
                    // Exit edit mode when switching subscriptions
                    isEditing = false
                }
                .onChange(of: focusedField) { _, _ in
                    // Select all text when a field receives focus
                    DispatchQueue.main.async {
                        NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
                    }
                }
            } else {
                EmptyDetailView()
            }
        }
    }

    // MARK: - Editable Header

    @ViewBuilder
    private func editableHeader(subscription: Subscription) -> some View {
        HStack(alignment: .center, spacing: 20) {
            // Logo (read-only — can't edit logo inline)
            ZStack {
                if let logoName = subscription.logoName, !logoName.isEmpty,
                   let nsImage = loadLogoImage(named: logoName) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.accentColor.opacity(0.12))
                    Text(editName.prefix(1).uppercased())
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(width: 80, height: 80)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.gray.opacity(0.12), lineWidth: 0.5)
            )

            VStack(alignment: .leading, spacing: 8) {
                TextField("Subscription Name", text: $editName)
                    .font(.title2.weight(.bold))
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .name)

                if isDuplicateName {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle")
                        Text("You already have a subscription with this name")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }

    // MARK: - Editable Billing Card

    private var editableBillingCard: some View {
        VStack(spacing: 0) {
            // Price
            editableRow(icon: "dollarsign.circle.fill", title: "Price", iconColor: .green) {
                TextField("0.00", text: $editPriceInput, prompt: Text("$0.00"))
                    .font(.callout.weight(.medium))
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.trailing)
                    .focused($focusedField, equals: .price)
                    .frame(maxWidth: 120)
                    .onChange(of: editPriceInput) { _, newValue in
                        let filtered = filterNumericInput(newValue)
                        if filtered != newValue {
                            editPriceInput = filtered
                        }
                        validateEditPrice(filtered)
                    }
            }

            Divider().padding(.leading, 46)

            // Billing Frequency
            editableRow(icon: "repeat", title: "Billing Cycle", iconColor: .blue) {
                Picker("", selection: $editFrequency) {
                    ForEach(BillingFrequency.allCases) { freq in
                        Text(freq.rawValue.capitalized).tag(freq)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .fixedSize()
                .focusable()
            }

            Divider().padding(.leading, 46)

            // Billing Date
            editableRow(icon: "calendar", title: "Billing Date", iconColor: Color(red: 0.18, green: 0.65, blue: 0.56)) {
                DatePicker("", selection: $editBillingDate, displayedComponents: .date)
                    .labelsHidden()
            }

            Divider().padding(.leading, 46)

            // Auto-Renew
            editableRow(icon: "arrow.circlepath", title: "Auto-Renewal", iconColor: editAutoRenew ? .green : .red) {
                Toggle("", isOn: $editAutoRenew)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(Color("BrandPink"))
            }
        }
        .cardBackground()
    }

    // MARK: - Editable Account Card

    private var editableAccountCard: some View {
        VStack(spacing: 0) {
            // Category
            editableRow(icon: "tag.fill", title: "Category", iconColor: .purple) {
                TextField("e.g. Streaming", text: $editCategory)
                    .font(.callout.weight(.medium))
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 180)
                    .focused($focusedField, equals: .category)
            }

            Divider().padding(.leading, 46)

            // Website
            editableRow(icon: "safari", title: "Website", iconColor: .blue) {
                TextField("example.com", text: $editURL)
                    .font(.callout.weight(.medium))
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 200)
                    .focused($focusedField, equals: .website)
            }
        }
        .cardBackground()
    }

    // MARK: - Editable Reminder Card

    private var editableReminderCard: some View {
        VStack(spacing: 0) {
            editableRow(
                icon: editRemindToCancel ? "bell.fill" : "bell.slash.fill",
                title: "Remind to Cancel",
                iconColor: editRemindToCancel ? .orange : .orange.opacity(0.35)
            ) {
                Toggle("", isOn: $editRemindToCancel)
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .tint(Color("BrandPink"))
                    .onChange(of: editRemindToCancel) { _, newValue in
                        guard newValue else { return }
                        // Smart default: next billing date minus 3 days, or 30 days from now
                        if editFrequency != .none {
                            let nextBilling = editFrequency.nextBillingDate(from: editBillingDate)
                            if let smartDate = Calendar.current.date(byAdding: .day, value: -3, to: nextBilling),
                               smartDate > Date() {
                                editReminderDate = smartDate
                            } else {
                                editReminderDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
                            }
                        } else {
                            editReminderDate = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
                        }
                    }
            }

            if editRemindToCancel {
                Divider().padding(.leading, 46)

                editableRow(icon: "calendar.badge.clock", title: "Reminder Date", iconColor: .orange) {
                    DatePicker("", selection: $editReminderDate, displayedComponents: .date)
                        .labelsHidden()
                }
            }
        }
        .cardBackground()
    }

    // MARK: - Editable Row Helper

    private func editableRow<Content: View>(
        icon: String,
        title: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(iconColor)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            Text(title)
                .font(.callout)
                .foregroundStyle(.primary)

            Spacer()

            content()
        }
        .padding(.vertical, 10)
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
            HStack(spacing: 5) {
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                Text(domain)
                    .font(.callout)
            }
            .foregroundStyle(Color.accentColor.opacity(0.7))
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

    // MARK: - Edit Helpers

    private func populateEditFields() {
        guard let subscription = selectedSubscription else { return }
        editName = subscription.accountName
        editCategory = subscription.category ?? ""
        editURL = subscription.accountURL ?? ""
        editPrice = subscription.price
        editPriceInput = String(format: "%.2f", subscription.price)
        editBillingDate = subscription.billingDate ?? Date()
        editFrequency = BillingFrequency(rawValue: subscription.billingFrequency) ?? .none
        editAutoRenew = subscription.autoRenew
        editRemindToCancel = subscription.remindToCancel
        editReminderDate = subscription.cancelReminderDate ?? Date()
    }

    private func filterNumericInput(_ input: String) -> String {
        var result = ""
        var hasDecimal = false
        for char in input {
            if char.isNumber {
                result.append(char)
            } else if char == "." && !hasDecimal {
                hasDecimal = true
                result.append(char)
            }
            // Skip all other characters (letters, symbols, etc.)
        }
        return result
    }

    private func validateEditPrice(_ input: String) {
        if input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            editPrice = 0.0
        } else if let value = Double(input), value >= 0 {
            editPrice = value
        } else {
            editPrice = nil
        }
    }

    private func saveEdits() {
        guard let subscription = selectedSubscription else { return }

        let previousURL = subscription.accountURL

        subscription.accountName = editName.capitalized.trimmingCharacters(in: .whitespacesAndNewlines)
        subscription.category = editCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? nil
            : editCategory.trimmingCharacters(in: .whitespacesAndNewlines)
        subscription.price = editPrice ?? 0.0
        subscription.billingDate = editBillingDate
        subscription.billingFrequency = editFrequency.rawValue
        subscription.autoRenew = editAutoRenew
        subscription.remindToCancel = editRemindToCancel
        subscription.cancelReminderDate = editRemindToCancel ? editReminderDate : nil
        subscription.lastModified = Date()

        let newURL = editURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let didChangeURL = previousURL != newURL
        subscription.accountURL = newURL.isEmpty ? nil : newURL

        // Reset logo if URL changed
        if didChangeURL || (subscription.logoName?.isEmpty ?? true) {
            if subscription.logoName != nil {
                LogoFetchService.shared.deleteLogo(for: subscription)
            }
            subscription.logoName = nil
        }

        try? modelContext.save()

        // Re-fetch logo if needed
        if subscription.logoName == nil {
            Task {
                await LogoFetchService.shared.fetchLogo(for: subscription, in: modelContext)
            }
        }

        // Handle notifications
        if editRemindToCancel {
            NotificationService.shared.scheduleCancelReminder(for: subscription)
        } else {
            NotificationService.shared.removeNotification(for: subscription)
        }
    }

    // MARK: - Logo Color Extraction

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
