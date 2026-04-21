//
//  SubscriptionIdentityHeaderView.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/20/26.
//

import SwiftUI

struct SubscriptionIdentityHeaderView<NameContent: View, CategoryContent: View, TrailingContent: View>: View {
    let logoName: String?
    let fallbackName: String
    @ViewBuilder var nameContent: NameContent
    @ViewBuilder var categoryContent: CategoryContent
    @ViewBuilder var trailingContent: TrailingContent

    var body: some View {
        HStack(spacing: 14) {
            artworkView

            VStack(alignment: .leading, spacing: 2) {
                nameContent
                    .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)

                categoryContent
                    .frame(maxWidth: .infinity, minHeight: 22, alignment: .leading)
            }

            Spacer(minLength: 12)

            trailingContent
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var artworkView: some View {
        ZStack {
            if let logoName, !logoName.isEmpty, let uiImage = loadLogoImage(named: logoName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(placeholderBackground)

                Text(placeholderInitial)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(placeholderForeground)
            }
        }
        .frame(width: 48, height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.primary.opacity(0.06), lineWidth: 0.8)
        )
    }

    private var placeholderInitial: String {
        let trimmed = fallbackName.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(trimmed.prefix(1)).uppercased().isEmpty ? "S" : String(trimmed.prefix(1)).uppercased()
    }

    private var placeholderBackground: Color {
        let palette: [Color] = [.pink, .indigo, .teal, .orange]
        let index = abs(fallbackName.hashValue) % palette.count
        return palette[index].opacity(0.14)
    }

    private var placeholderForeground: Color {
        let palette: [Color] = [.pink, .indigo, .teal, .orange]
        let index = abs(fallbackName.hashValue) % palette.count
        return palette[index]
    }

    private func loadLogoImage(named logoName: String) -> UIImage? {
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let logoPath = supportDir
            .appendingPathComponent("Logos", isDirectory: true)
            .appendingPathComponent("\(logoName).png")

        guard let data = try? Data(contentsOf: logoPath) else { return nil }
        return UIImage(data: data)
    }
}

#Preview("Display") {
    List {
        Section {
            SubscriptionIdentityHeaderView(
                logoName: nil,
                fallbackName: "Netflix"
            ) {
                Text("Netflix")
                    .font(.title3.weight(.semibold))
            } categoryContent: {
                Text("Streaming")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } trailingContent: {
                Text(15.99, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.title3.weight(.semibold))
            }
        }
    }
    .listStyle(.insetGrouped)
}

#Preview("Editing") {
    @Previewable @State var accountName = "Spotify"
    @Previewable @State var category = "Music"

    List {
        Section {
            SubscriptionIdentityHeaderView(
                logoName: nil,
                fallbackName: accountName
            ) {
                TextField("Name", text: $accountName)
                    .font(.title3.weight(.semibold))
                    .textFieldStyle(.plain)
            } categoryContent: {
                TextField("Category", text: $category)
                    .font(.subheadline)
                    .textFieldStyle(.plain)
            } trailingContent: {
                Text(11.99, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.title3.weight(.semibold))
            }
        }
    }
    .listStyle(.insetGrouped)
}
