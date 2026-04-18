//
//  SettingsTab.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI

struct SettingsTab: View {
    @AppStorage(AppSettingKey.preferredAppearanceMode)
    private var appearanceMode: String = AppSettingDefault.preferredAppearanceMode

    @AppStorage(AppSettingKey.iCloudSyncEnabled)
    private var iCloudSyncEnabled: Bool = AppSettingDefault.iCloudSyncEnabled

    @AppStorage(AppSettingKey.billingRemindersEnabled)
    private var billingRemindersEnabled: Bool = AppSettingDefault.billingRemindersEnabled

    @AppStorage(AppSettingKey.cancelRemindersEnabled)
    private var cancelRemindersEnabled: Bool = AppSettingDefault.cancelRemindersEnabled

    @State private var showRestartAlert = false

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                iCloudSection
                notificationsSection
                aboutSection
            }
            .navigationTitle("Settings")
            .alert("Restart Required", isPresented: $showRestartAlert) {
                Button("OK") { }
            } message: {
                Text("Quit and reopen Supscription for this change to take effect.")
            }
        }
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        Section {
            Picker("Theme", selection: $appearanceMode) {
                ForEach(AppAppearanceMode.allCases) { mode in
                    Text(mode.title).tag(mode.rawValue)
                }
            }
        } header: {
            Text("Appearance")
        } footer: {
            Text("Choose how Supscription looks on this device.")
        }
    }

    // MARK: - iCloud

    private var iCloudSection: some View {
        Section {
            Toggle("iCloud Sync", isOn: $iCloudSyncEnabled)
                .onChange(of: iCloudSyncEnabled) { _, _ in
                    showRestartAlert = true
                }
        } header: {
            Text("Data")
        } footer: {
            Text(iCloudSyncEnabled
                 ? "Your subscriptions sync automatically across your devices via iCloud."
                 : "Sync is disabled. Subscriptions are stored locally on this device only.")
        }
    }

    // MARK: - Notifications

    private var notificationsSection: some View {
        Section {
            Toggle("Billing Reminders", isOn: $billingRemindersEnabled)
            Toggle("Cancel Reminders", isOn: $cancelRemindersEnabled)
        } header: {
            Text("Notifications")
        } footer: {
            Text("Manage which reminders Supscription can send you. Notification permissions can be changed in System Settings.")
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            LabeledContent("Version", value: appVersion)

            Button {
                openAppSettings()
            } label: {
                HStack {
                    Text("System Settings")
                    Spacer()
                    Image(systemName: "arrow.up.forward.app")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("About")
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }

    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsTab()
}
