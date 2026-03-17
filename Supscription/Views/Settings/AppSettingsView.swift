//
//  AppSettingsView.swift
//  Supscription
//
//  Created by Richie Flores on 3/16/26.
//

import SwiftUI

struct AppSettingsView: View {
    @AppStorage("preferredAppearanceMode") private var appearanceMode: String = "system"

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
        }
        .formStyle(.grouped)
        .frame(width: 360)
        .fixedSize()
        .onChange(of: appearanceMode) { _, newValue in
            applyAppearance(newValue)
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
