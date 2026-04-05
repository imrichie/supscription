//
//  SettingsPlaceholder.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI

struct SettingsPlaceholder: View {
    var body: some View {
        List {
            Section("Sync") {
                Label("iCloud Sync", systemImage: "icloud")
                    .foregroundStyle(.secondary)
            }

            Section("Appearance") {
                Label("Theme", systemImage: "paintbrush")
                    .foregroundStyle(.secondary)
            }

            Section("Notifications") {
                Label("Reminders", systemImage: "bell")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsPlaceholder()
    }
}
