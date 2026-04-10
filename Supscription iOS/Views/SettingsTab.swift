//
//  SettingsTab.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI

struct SettingsTab: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Sync") {
                    Label("iCloud Sync", systemImage: "icloud.fill")
                        .foregroundStyle(.secondary)
                }

                Section("Appearance") {
                    Label("Theme", systemImage: "sun.max.fill")
                        .foregroundStyle(.secondary)
                }

                Section("Notifications") {
                    Label("Reminders", systemImage: "bell.badge.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsTab()
}
