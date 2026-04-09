//
//  ContentView.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Subscriptions", systemImage: "creditcard") {
                SubscriptionsTab()
            }

            Tab("Dashboard", systemImage: "chart.pie") {
                DashboardTab()
            }

            Tab("Settings", systemImage: "gearshape") {
                SettingsTab()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(previewContainer)
}
