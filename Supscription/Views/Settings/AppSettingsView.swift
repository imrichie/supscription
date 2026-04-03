//
//  AppSettingsView.swift
//  Supscription
//
//  Created by Richie Flores on 3/16/26.
//

import SwiftUI

struct AppSettingsView: View {
    @AppStorage("preferredAppearanceMode") private var appearanceMode: String = "system"
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled: Bool = true
    @State private var showRestartAlert: Bool = false

    var body: some View {
        Form {
            Section {
                Picker("Appearance", selection: $appearanceMode) {
                    Text("System").tag("system")
                    Text("Light").tag("light")
                    Text("Dark").tag("dark")
                }
                .pickerStyle(.radioGroup)
            } header: {
                Text("Appearance")
            }

            Section {
                Toggle("Sync with iCloud", isOn: $iCloudSyncEnabled)
                    .onChange(of: iCloudSyncEnabled) { _, _ in
                        showRestartAlert = true
                    }

                Text(iCloudSyncEnabled
                    ? "Your subscriptions sync automatically across your devices via iCloud."
                    : "Sync is disabled. Your subscriptions are stored locally on this device only.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("iCloud")
            }
        }
        .formStyle(.grouped)
        .frame(width: 360)
        .fixedSize()
        .onChange(of: appearanceMode) { _, newValue in
            applyAppearance(newValue)
        }
        .alert("Restart Required", isPresented: $showRestartAlert) {
            Button("OK") { }
        } message: {
            Text("Quit and reopen Supscription for this change to take effect.")
        }
    }

    private func applyAppearance(_ mode: String) {
        switch mode {
        case "light":
            NSApp.appearance = NSAppearance(named: .aqua)
        case "dark":
            NSApp.appearance = NSAppearance(named: .darkAqua)
        default:
            NSApp.appearance = nil
        }
    }
}
