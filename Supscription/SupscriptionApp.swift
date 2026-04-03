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
            let container = sharedModelContainer
            NotificationCenter.default.addObserver(
                forName: NSNotification.Name("NSPersistentStoreRemoteChange"),
                object: nil,
                queue: .main
            ) { _ in
                print("[Sync] Remote change detected — CloudKit pulled new data")
                let refreshContext = container.mainContext
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
                    print("[Sync] Context saved — inserted: \(inserted), updated: \(updated), deleted: \(deleted)")
                }
            }
            
            // One-time dedup cleanup after CloudKit sync created duplicates
            if !UserDefaults.standard.bool(forKey: "hasRunCloudKitDedup") {
                let allSubs = (try? context.fetch(FetchDescriptor<Subscription>())) ?? []
                var seen: [String: Subscription] = [:]
                var dupes: [Subscription] = []

                for sub in allSubs {
                    let key = sub.accountName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                    if let existing = seen[key] {
                        // Keep the one with the most recent lastModified
                        if sub.lastModified > existing.lastModified {
                            dupes.append(existing)
                            seen[key] = sub
                        } else {
                            dupes.append(sub)
                        }
                    } else {
                        seen[key] = sub
                    }
                }

                if !dupes.isEmpty {
                    print("[Sync] Removing \(dupes.count) duplicate subscriptions:")
                    for dupe in dupes {
                        print("[Sync]   - \(dupe.accountName) | id: \(dupe.id.uuidString.prefix(8))…")
                        context.delete(dupe)
                    }
                    try? context.save()
                    print("[Sync] Dedup complete. \(allSubs.count - dupes.count) unique subscriptions remain.")
                } else {
                    print("[Sync] No duplicates found.")
                }

                UserDefaults.standard.set(true, forKey: "hasRunCloudKitDedup")
            }

            if DevFlags.shouldResetOnboarding {
                print("[Dev] Wiping all data and resetting onboarding...")
                
                deleteAllSubscriptions(in: context)
                try? context.save()
                
                UserDefaults.standard.set(false, forKey: "hasSeenWelcomeSheet")
                UserDefaults.standard.removeObject(forKey: "lastSelectedSubscriptionID")
            }
            
            if DevFlags.shouldSeedSampleData {
                let existingCount = (try? context.fetchCount(FetchDescriptor<Subscription>())) ?? 0
                if existingCount == 0 {
                    print("[Dev] No existing data — seeding sample subscriptions...")
                    populateSampleDataIfNeeded(in: context)

                    for sub in sampleSubscriptions {
                        context.insert(sub)
                        Task {
                            await LogoFetchService.shared.fetchLogo(for: sub, in: context)
                        }
                    }
                } else {
                    print("[Dev] Store already has \(existingCount) subscriptions — skipping seed.")
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
