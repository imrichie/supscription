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
//            
//            #if DEBUG
//            // populateSampleDataIfNeeded(in: sharedModelContainer.mainContext)
//            #endif
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

//#if DEBUG
//private let shouldSeedSampleData: Bool = false
//
//private func populateSampleDataIfNeeded(in context: ModelContext) {
//    guard shouldSeedSampleData else { return }
//    
//    let fetch = FetchDescriptor<Subscription>()
//    if (try? context.fetch(fetch).isEmpty) == true {
//        for subscription in sampleSubscriptions {
//            context.insert(subscription)
//        }
//        try? context.save()
//    }
//}
//#endif

