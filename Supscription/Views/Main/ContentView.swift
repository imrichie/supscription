//
//  ContentView.swift
//  Supscription
//
//  Created by Richie Flores on 12/30/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // MARK: - Data
    @Environment(\.modelContext) private var context
    @Query var subscriptions: [Subscription]

    // MARK: - State
    @State var selectedDestination: SidebarDestination = .subscriptions(category: AppConstants.Category.all)
    @State var selectedSubscription: Subscription? = nil
    @State var searchText: String = ""
    @State var isAddingSubscription: Bool = false
    @State var activeSheet: ActiveSheet?

    // MARK: - Persistance
    @AppStorage("hasSeenWelcomeSheet") var hasSeenWelcomeSheet: Bool = false
    @AppStorage("lastSelectedSubscriptionID") var lastSelectedID: String?
    @AppStorage("lastSelectedCategory") private var lastSelectedCategory: String?

    // MARK: - View
    var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            contentColumnView
        }
        .onChange(of: selectedDestination) { _, newValue in
            searchText = ""
        }
        .navigationTitle(navigationTitle)
        .navigationSubtitle(navigationSubtitle)
        .onAppear {
            #if DEBUG
            if DevFlags.shouldResetOnboarding {
                print("[Dev] Resetting onboarding state...")
                hasSeenWelcomeSheet = false
                lastSelectedID = nil
            }
            #endif

            if !hasSeenWelcomeSheet && subscriptions.isEmpty {
                print("[Dev] Showing welcome onboarding sheet.")
                activeSheet = .welcome
                return
            }

            // Restore category first
            if let lastCat = lastSelectedCategory,
               categoryCounts.keys.contains(lastCat) || lastCat == AppConstants.Category.all {
                selectedDestination = .subscriptions(category: lastCat)
                print("DEBUG - Restored category: \(lastCat)")
            } else {
                selectedDestination = .subscriptions(category: AppConstants.Category.all)
            }

            // Restore subscription
            if let lastID = lastSelectedID,
               let restored = subscriptions.first(where: { $0.id.uuidString == lastID }) {
                let restoredCategory = restored.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? AppConstants.Category.uncategorized
                let isInAll = selectedDestination == .subscriptions(category: AppConstants.Category.all)
                let isInSameCategory = selectedDestination == .subscriptions(category: restoredCategory)

                if isInAll || isInSameCategory {
                    selectedSubscription = restored
                    print("DEBUG - Restored subscription: \(restored.accountName)")
                } else {
                    selectedSubscription = nil
                    print("DEBUG - Skipped restoring subscription — category mismatch")
                }
            }
        }
        .onChange(of: selectedSubscription) { _, newValue in
            if let new = newValue {
                lastSelectedID = new.id.uuidString
                print("DEBUG - Saved lastSelectedID on selection: \(lastSelectedID ?? "nil")")
            }
        }
        .onChange(of: selectedDestination) { _, newValue in
            if case .subscriptions(let category) = newValue, let cat = category {
                lastSelectedCategory = cat
                print("DEBUG - Saved lastSelectedCategory: \(cat)")
            }
        }
        .sheet(item: $activeSheet, content: sheetView)
    }
}
