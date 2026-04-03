//
//  SupscriptionApp.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI
import SwiftData

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
        let schema = Schema([Subscription.self])
        let iCloudEnabled = UserDefaults.standard.object(forKey: "iCloudSyncEnabled") as? Bool ?? true

        // Attempt CloudKit-enabled container first, fall back to local-only
        if iCloudEnabled {
            do {
                let config = ModelConfiguration(
                    schema: schema,
                    cloudKitDatabase: .automatic
                )
                sharedModelContainer = try ModelContainer(for: schema, configurations: [config])
            } catch {
                #if DEBUG
                print("[Sync] CloudKit initialization failed: \(error). Falling back to local-only storage.")
                #endif
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

        #if DEBUG
        let context = sharedModelContainer.mainContext
        let fetchAll = FetchDescriptor<Subscription>()
        if let count = try? context.fetchCount(fetchAll) {
            print("[Sync] iCloud \(iCloudEnabled ? "enabled" : "disabled") — \(count) subscriptions in local store")
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
