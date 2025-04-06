//
//  SupscriptionApp.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI
import SwiftData

@main
struct SubscriptionApp: App {
    var sharedModelContainer: ModelContainer
    
    
    init() {
        do {
            let schema = Schema([Subscription.self])
            sharedModelContainer = try ModelContainer(for: schema)
            
            #if DEBUG
            let context = sharedModelContainer.mainContext
            
            if DevFlags.shouldSeedSampleData {
                print("[Dev] Wiping all data and seeding sample subscriptions.")
                deleteAllSubscriptions(in: context)
                populateSampleDataIfNeeded(in: context)
            } else if DevFlags.shouldResetOnboarding {
                print("[Dev] Resetting onboarding and clearing all data.")
                deleteAllSubscriptions(in: context)
            }
            #endif
            
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}

// Only used for dev builds to seed the UI with fake subscriptions
#if DEBUG
fileprivate func populateSampleDataIfNeeded(in context: ModelContext) {
    do {
        let fetch = FetchDescriptor<Subscription>()
        if try context.fetch(fetch).isEmpty {
            print("[Dev] Seeding sample subscriptions…")
            for subscription in sampleSubscriptions {
                context.insert(subscription)
            }
            try context.save()
            print("[Dev] Sample data seeded successfully")
        } else {
            print("[Dev] Sample data already exists — skipping seeding.")
        }
    } catch {
        print("[Dev] Failed to seed sample data: \(error)")
    }
}

fileprivate func deleteAllSubscriptions(in context: ModelContext) {
    let fetch = FetchDescriptor<Subscription>()
    do {
        let existing = try context.fetch(fetch)
        existing.forEach { context.delete($0) }
        try context.save()
        print("[Dev] Deleted all existing subscriptions.")
    } catch {
        print("[Dev] Failed to delete existing data: \(error)")
    }
}

#endif
