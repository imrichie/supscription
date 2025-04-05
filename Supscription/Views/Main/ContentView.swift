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
    
    #if DEBUG
    private let shouldResetOnboarding = false
    #endif
    
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
            if shouldResetOnboarding {
                hasSeenWelcomeSheet = false
            }
            #endif
            
            if !hasSeenWelcomeSheet && subscriptions.isEmpty {
                activeSheet = .welcome
            }
        }
        .sheet(item: $activeSheet, content: sheetView)
    }
}
