//
//  Supscription_iOSApp.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/3/26.
//

import SwiftUI
import SwiftData

@main
struct Supscription_iOSApp: App {
    var sharedModelContainer: ModelContainer

    init() {
        let schema = Schema([Subscription.self])
        let iCloudEnabled = UserDefaults.standard.object(forKey: "iCloudSyncEnabled") as? Bool ?? true

        if iCloudEnabled {
            do {
                let config = ModelConfiguration(
                    schema: schema,
                    cloudKitDatabase: .automatic
                )
                sharedModelContainer = try ModelContainer(for: schema, configurations: [config])
            } catch {
                do {
                    let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
                    sharedModelContainer = try ModelContainer(for: schema, configurations: [localConfig])
                } catch {
                    fatalError("Failed to initialize ModelContainer: \(error)")
                }
            }
        } else {
            do {
                let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
                sharedModelContainer = try ModelContainer(for: schema, configurations: [localConfig])
            } catch {
                fatalError("Failed to initialize ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            iOSContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
