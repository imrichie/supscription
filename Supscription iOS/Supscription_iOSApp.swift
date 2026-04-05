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
                #if DEBUG
                .task {
                    await logSyncedSubscriptions()
                }
                #endif
        }
        .modelContainer(sharedModelContainer)
    }

    #if DEBUG
    @MainActor
    private func logSyncedSubscriptions() async {
        let context = sharedModelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<Subscription>(
            sortBy: [SortDescriptor(\.accountName)]
        )

        do {
            let subscriptions = try context.fetch(fetchDescriptor)
            print("[Sync] iCloud \(UserDefaults.standard.object(forKey: "iCloudSyncEnabled") as? Bool ?? true ? "enabled" : "disabled")")
            print("[Sync] Found \(subscriptions.count) subscription(s):")
            for sub in subscriptions {
                print("  → \(sub.accountName) — \(String(format: "$%.2f", sub.price))/\(sub.billingFrequency)")
            }
            if subscriptions.isEmpty {
                print("[Sync] No subscriptions found. If you have data on Mac, allow a few moments for CloudKit to sync.")
            }
        } catch {
            print("[Sync] Failed to fetch subscriptions: \(error.localizedDescription)")
        }
    }
    #endif
}
