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
        
        // Clear existing data and insert fresh dummy data
        Task {
            let context = container.mainContext
            
            do {
                // Step 1: Delete all existing subscriptions
                let existingSubscriptions = try context.fetch(FetchDescriptor<Subscription>())
                existingSubscriptions.forEach { context.delete($0) }
                try context.save()
                
                // Step 2: Insert fresh dummy data
                for sub in sampleSubscriptions {
                    context.insert(sub)
                }
                try context.save()
                
                print("Dummy data inserted successfully!")
                
                // Step 3: Fetch and verify stored subscriptions
                let updatedSubscriptions = try context.fetch(FetchDescriptor<Subscription>())
                print("Found \(updatedSubscriptions.count) subscriptions:")
                updatedSubscriptions.forEach { print("\($0.accountName)") }
                
            } catch {
                print("Error resetting database: \(error)")
            }
        }
        
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
