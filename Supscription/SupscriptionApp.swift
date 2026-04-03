//
//  SupscriptionApp.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI
import SwiftData
import CoreData

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
@main
struct SubscriptionApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("preferredAppearanceMode") private var preferredAppearanceMode: String = "system"
    @State private var selectionStore = SubscriptionSelectionStore()
    
    var sharedModelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([Subscription.self])
            let config = ModelConfiguration(
                schema: schema,
                cloudKitDatabase: .automatic
            )
            sharedModelContainer = try ModelContainer(for: schema, configurations: [config])

            #if DEBUG
            print("[Sync] ──────────────────────────────────────")
            print("[Sync] ModelContainer initialized with CloudKit sync enabled")
            print("[Sync] Store URL: \(config.url)")

            let context = sharedModelContainer.mainContext
            let fetchAll = FetchDescriptor<Subscription>(sortBy: [SortDescriptor(\.accountName)])
            if let subs = try? context.fetch(fetchAll) {
                print("[Sync] Local store contains \(subs.count) subscriptions:")
                for (i, sub) in subs.enumerated() {
                    print("[Sync]   \(i + 1). \(sub.accountName) | \(sub.category ?? "nil") | $\(String(format: "%.2f", sub.price)) | id: \(sub.id.uuidString.prefix(8))…")
                }
            }
            print("[Sync] ──────────────────────────────────────")

            // Monitor CloudKit sync events via NSPersistentCloudKitContainer notifications
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("NSPersistentStoreRemoteChange"),
                object: nil,
                queue: .main
            ) { notification in
                print("[Sync] ⬇ Remote change detected — CloudKit pulled new data")
                let refreshContext = sharedModelContainer.mainContext
                let refreshFetch = FetchDescriptor<Subscription>()
                if let count = try? refreshContext.fetchCount(refreshFetch) {
                    print("[Sync]   Local store now contains \(count) subscriptions")
                }
            }

            // Monitor Core Data save notifications (records being pushed)
            NotificationCenter.default.addObserver(
                forName: .NSManagedObjectContextDidSave,
                object: nil,
                queue: .main
            ) { notification in
                let inserted = (notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>)?.count ?? 0
                let updated = (notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>)?.count ?? 0
                let deleted = (notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>)?.count ?? 0
                if inserted > 0 || updated > 0 || deleted > 0 {
                    print("[Sync] ⬆ Context saved — inserted: \(inserted), updated: \(updated), deleted: \(deleted)")
                }
            }
            
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
                .environment(selectionStore)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    applySavedAppearance()
                }
        }
        .defaultSize(width: 1000, height: 700)
        .commands {
            SidebarCommands()
            CommandGroup(replacing: .newItem) {
                Button("New Subscription") {
                    NotificationCenter.default.post(name: .newSubscription, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            CommandGroup(after: .pasteboard) {
                Button("Edit Subscription") {
                    NotificationCenter.default.post(name: .editSubscription, object: nil)
                }
                .keyboardShortcut("e", modifiers: .command)
                .disabled(selectionStore.selected == nil)
                
                Button("Delete Subscription") {
                    NotificationCenter.default.post(name: .deleteSubscription, object: nil)
                }
                .keyboardShortcut("d", modifiers: .command)
                .disabled(selectionStore.selected == nil)
            }
        }

        Settings {
            AppSettingsView()
        }
    }

    // MARK: - Appearance Logic

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
