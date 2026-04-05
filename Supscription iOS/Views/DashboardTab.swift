//
//  DashboardTab.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI

struct DashboardTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Dashboard",
                systemImage: "chart.pie",
                description: Text("Spending overview and upcoming renewals will appear here.")
            )
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    DashboardTab()
}
