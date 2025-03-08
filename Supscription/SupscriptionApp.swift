//
//  SupscriptionApp.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI
import SwiftData

@main
struct SupscriptionApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Subscription.self])
        let container = try! ModelContainer(for: schema)
        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
