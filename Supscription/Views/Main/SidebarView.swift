//
//  SidebarView.swift
//  Supscription
//
//  Created by Richie Flores on 1/1/25.
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    // MARK: - Environment
    @Environment(\.modelContext) private var modelContext
    @Query private var allSubscriptions: [Subscription]

    // MARK: - Bindings
    @Binding var selectedDestination: SidebarDestination
    @Binding var searchText: String

    // MARK: - Data
    let orderedCategoryNames: [String]
    let remindToCancelCount: Int

    // MARK: - State (Category Management)
    @State private var categoryToRename: String?
    @State private var renameText: String = ""
    @State private var showRenameAlert: Bool = false
    @State private var categoryToDelete: String?
    @State private var dropTargetCategory: String?

    // MARK: - View
    var body: some View {
        List(selection: $selectedDestination) {
            // General Section
            Section(header: Text("General")) {
                Label {
                    Text(AppConstants.Category.all)
                } icon: {
                    Image(systemName: "square.stack.3d.up")
                        .foregroundColor(.secondary)
                }
                .tag(SidebarDestination.subscriptions(category: AppConstants.Category.all))

                Label {
                    Text("Dashboard")
                } icon: {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundColor(.secondary)
                }
                .tag(SidebarDestination.dashboard)

                Label {
                    Text("To Cancel")
                } icon: {
                    Image(systemName: "bell.badge")
                        .foregroundColor(.secondary)
                }
                .badge(remindToCancelCount > 0 ? remindToCancelCount : 0)
                .tag(SidebarDestination.reminders)
            }

            // Categories Section
            Section(header: Text("Categories")) {
                ForEach(orderedCategoryNames, id: \.self) { category in
                    Text(category)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(selectedDestination == .subscriptions(category: category) ? .primary : .secondary)
                    .tag(SidebarDestination.subscriptions(category: category))
                    .listRowBackground(
                        dropTargetCategory == category
                            ? RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color("BrandPurple").opacity(0.15))
                            : nil
                    )
                    .onDrop(of: [.text], isTargeted: Binding(
                        get: { dropTargetCategory == category },
                        set: { isTargeted in
                            dropTargetCategory = isTargeted ? category : nil
                        }
                    )) { providers in
                        handleDrop(providers: providers, onto: category)
                    }
                    .contextMenu {
                        Button {
                            categoryToRename = category
                            renameText = category
                            showRenameAlert = true
                        } label: {
                            Label("Rename", systemImage: "pencil")
                        }

                        Divider()

                        Button(role: .destructive) {
                            categoryToDelete = category
                        } label: {
                            Label("Delete Category", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .confirmationDialog(
            "Delete \"\(categoryToDelete ?? "")\"?",
            isPresented: Binding(
                get: { categoryToDelete != nil },
                set: { if !$0 { categoryToDelete = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                if let category = categoryToDelete {
                    deleteCategory(category)
                    categoryToDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                categoryToDelete = nil
            }
        } message: {
            Text("All subscriptions in this category will be moved to Uncategorized. This cannot be undone.")
        }
        .alert("Rename Category", isPresented: $showRenameAlert) {
            TextField("Category name", text: $renameText)
            Button("Rename") {
                if let oldName = categoryToRename {
                    commitRename(from: oldName)
                }
            }
            Button("Cancel", role: .cancel) {
                categoryToRename = nil
            }
        } message: {
            Text("Enter a new name for \"\(categoryToRename ?? "")\".")
        }
        .onChange(of: selectedDestination) {
            if selectedDestination == .subscriptions(category: AppConstants.Category.all) {
                searchText = ""
            }
        }
    }

    // MARK: - Category Management

    private func commitRename(from oldName: String) {
        let newName = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newName.isEmpty, newName != oldName else {
            categoryToRename = nil
            return
        }

        let affected = allSubscriptions.filter {
            $0.category?.trimmingCharacters(in: .whitespacesAndNewlines) == oldName
        }
        for subscription in affected {
            subscription.category = newName
            subscription.lastModified = Date()
        }
        try? modelContext.save()

        // Update selection if viewing the renamed category
        if selectedDestination == .subscriptions(category: oldName) {
            selectedDestination = .subscriptions(category: newName)
        }

        categoryToRename = nil
    }

    private func handleDrop(providers: [NSItemProvider], onto category: String) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: "public.text", options: nil) { item, _ in
            guard let data = item as? Data,
                  let uuidString = String(data: data, encoding: .utf8),
                  let uuid = UUID(uuidString: uuidString) else { return }

            DispatchQueue.main.async {
                guard let subscription = allSubscriptions.first(where: { $0.id == uuid }) else { return }
                subscription.category = category
                subscription.lastModified = Date()
                try? modelContext.save()
            }
        }
        return true
    }

    private func deleteCategory(_ category: String) {
        let affected = allSubscriptions.filter {
            $0.category?.trimmingCharacters(in: .whitespacesAndNewlines) == category
        }
        for subscription in affected {
            subscription.category = AppConstants.Category.uncategorized
            subscription.lastModified = Date()
        }
        try? modelContext.save()

        // Navigate away if viewing the deleted category
        if selectedDestination == .subscriptions(category: category) {
            selectedDestination = .subscriptions(category: AppConstants.Category.all)
        }
    }
}
