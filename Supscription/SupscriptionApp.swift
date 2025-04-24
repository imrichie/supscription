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
    @AppStorage("preferredAppearanceMode") private var preferredAppearanceMode: String = "system"
    var sharedModelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([Subscription.self])
            sharedModelContainer = try ModelContainer(for: schema)
            
            #if DEBUG
            let context = sharedModelContainer.mainContext
            
            if DevFlags.shouldResetOnboarding {
                print("[Dev] Wiping all data and resetting onboarding...")
                
                deleteAllSubscriptions(in: context)
                try? context.save()
                
                UserDefaults.standard.set(false, forKey: "hasSeenWelcomeSheet")
                UserDefaults.standard.removeObject(forKey: "lastSelectedSubscriptionID")
            }
            
            if DevFlags.shouldSeedSampleData {
                print("[Dev] Wiping all data and seeding sample subscriptions...")
                deleteAllSubscriptions(in: context)
                
                print("[Dev] Seeding sample data…")
                populateSampleDataIfNeeded(in: context)
                
                for sub in sampleSubscriptions {
                    context.insert(sub)
                    Task {
                        await LogoFetchService.shared.fetchLogo(for: sub, in: context)
                    }
                }
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
                .onAppear {
                    applySavedAppearance()
                }
        }
        .commands {
            SidebarCommands()
            CommandGroup(after: .sidebar) {
                Divider()
                Button("Toggle Dark Mode") {
                    toggleDarkMode()
                }
                .keyboardShortcut("d", modifiers: [.command, .shift]) // Optional
            }
        }
    }
    // MARK: - Appearance Logic
    private func toggleDarkMode() {
        let current = NSApp.effectiveAppearance.name
        
        if current == .darkAqua {
            NSApp.appearance = NSAppearance(named: .aqua)
            preferredAppearanceMode = "light"
        } else {
            NSApp.appearance = NSAppearance(named: .darkAqua)
            preferredAppearanceMode = "dark"
        }
    }
    
    private func applySavedAppearance() {
        switch preferredAppearanceMode {
        case "light":
            NSApp.appearance = NSAppearance(named: .aqua)
        case "dark":
            NSApp.appearance = NSAppearance(named: .darkAqua)
        default:
            NSApp.appearance = nil // Fallback to system default
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
