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
    
    @State var selectedCategory: String? = AppConstants.Category.all
    @State var selectedSubscription: Subscription? = nil
    @State var searchText: String = ""
    @State var isAddingSubscription: Bool = false
    @State var activeSheet: ActiveSheet?
    @AppStorage("hasSeenWelcomeSheet") var hasSeenWelcomeSheet: Bool = false
    @AppStorage("lastSelectedSubscriptionID") var lastSelectedID: String?
    @AppStorage("lastSelectedCategory") private var lastSelectedCategory: String?
    
    // MARK: - View
    
    var body: some View {
        NavigationSplitView {
            sidebarView
        } content: {
            contentListView
        } detail: {
            detailView
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search")
        .onChange(of: selectedCategory) { oldValue, newValue in
            searchText = "" // reset search when any category is selected
        }
        .navigationTitle(selectedCategory ?? AppConstants.Category.all)
        .navigationSubtitle("\(filteredSubscriptions.count) Items")
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
            
            // ✅ Restore category first
            if let lastCat = lastSelectedCategory,
               categoryCounts.keys.contains(lastCat) || lastCat == AppConstants.Category.all {
                selectedCategory = lastCat
                print("DEBUG - Restored category: \(lastCat)")
            } else {
                selectedCategory = AppConstants.Category.all
            }
            
            // ✅ Now restore subscription
            if let lastID = lastSelectedID,
               let restored = subscriptions.first(where: { $0.id.uuidString == lastID }) {
                
                let restoredCategory = restored.category?.trimmingCharacters(in: .whitespacesAndNewlines) ?? AppConstants.Category.uncategorized
                let isInAll = selectedCategory == AppConstants.Category.all
                let isInSameCategory = restoredCategory == selectedCategory
                
                if isInAll || isInSameCategory {
                    selectedSubscription = restored
                    print("DEBUG - Restored subscription: \(restored.accountName)")
                } else {
                    selectedSubscription = nil
                    print("DEBUG - Skipped restoring subscription — category mismatch")
                }
            }
        }
        .onChange(of: selectedSubscription) { oldValue, newValue in
            if let new = newValue {
                lastSelectedID = new.id.uuidString
                print("DEBUG - Saved lastSelectedID on selection: \(lastSelectedID ?? "nil")")
            }
        }
        .onChange(of: selectedCategory) { oldValue, newValue in
            if let new = newValue {
                lastSelectedCategory = new
                print("DEBUG - Saved lastSelectedCategory on selection: \(lastSelectedCategory ?? "nil")")
            }
        }
        .sheet(item: $activeSheet, content: sheetView)
    }
}
