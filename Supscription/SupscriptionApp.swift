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
            let shouldSeedData = true
            if shouldSeedData {
                populateSampleDataIfNeeded(in: sharedModelContainer.mainContext)
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
    let fetch = FetchDescriptor<Subscription>()
    if (try? context.fetch(fetch).isEmpty) == true {
        for subscription in sampleSubscriptions {
            context.insert(subscription)
        }
        try? context.save()
    }
}
#endif
