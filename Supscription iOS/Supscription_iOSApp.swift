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

        #if DEBUG
        // Use local-only storage in debug to avoid CloudKit noise and speed up testing
        do {
            let config = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
            sharedModelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        #else
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
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                #if DEBUG
                .task {
                    await seedIfNeeded()
                    await logSyncedSubscriptions()
                }
                #endif
        }
        .modelContainer(sharedModelContainer)
    }

    #if DEBUG
    @MainActor
    private func seedIfNeeded() async {
        let context = sharedModelContainer.mainContext
        let fetch = FetchDescriptor<Subscription>()
        let count = (try? context.fetchCount(fetch)) ?? 0
        if count == 0 {
            print("[Dev] No subscriptions found — seeding sample data...")
            for subscription in sampleSubscriptions {
                context.insert(subscription)
            }
            try? context.save()
            print("[Dev] Seeded \(sampleSubscriptions.count) sample subscriptions")
        }
    }

    @MainActor
    private func logSyncedSubscriptions() async {
        let context = sharedModelContainer.mainContext
        let fetchDescriptor = FetchDescriptor<Subscription>(
            sortBy: [SortDescriptor(\.accountName)]
        )

        do {
            let subscriptions = try context.fetch(fetchDescriptor)
            print("[Sync] iCloud disabled (debug mode — local only)")
            print("[Sync] Found \(subscriptions.count) subscription(s):")
            for sub in subscriptions {
                print("  -> \(sub.accountName) — \(String(format: "$%.2f", sub.price))/\(sub.billingFrequency)")
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
