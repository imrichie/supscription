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
        do {
            sharedModelContainer = try SharedModelContainerFactory.makeSubscriptionContainer(schema: schema)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                #if DEBUG
                .task {
                    if DevFlags.shouldSeedSampleData {
                        await seedIfNeeded()
                    }
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

    #endif
}
