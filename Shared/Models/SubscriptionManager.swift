//
//  SubscriptionData.swift
//  Supscription
//
//  Created by Richie Flores on 1/9/25.
//

import Foundation
import SwiftData

enum AppSettingKey {
    static let preferredAppearanceMode = "preferredAppearanceMode"
    static let iCloudSyncEnabled = "iCloudSyncEnabled"
    static let billingRemindersEnabled = "billingRemindersEnabled"
    static let cancelRemindersEnabled = "cancelRemindersEnabled"
}

enum AppAppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

enum AppSettingDefault {
    static let preferredAppearanceMode = AppAppearanceMode.system.rawValue
    static let iCloudSyncEnabled = true
    static let billingRemindersEnabled = true
    static let cancelRemindersEnabled = true
}

enum SharedModelContainerFactory {
    static func makeSubscriptionContainer(
        schema: Schema,
        userDefaults: UserDefaults = .standard
    ) throws -> ModelContainer {
        let iCloudEnabled = userDefaults.object(forKey: AppSettingKey.iCloudSyncEnabled) as? Bool
            ?? AppSettingDefault.iCloudSyncEnabled

        if iCloudEnabled {
            do {
                let cloudConfig = ModelConfiguration(
                    schema: schema,
                    cloudKitDatabase: .automatic
                )
                return try ModelContainer(for: schema, configurations: [cloudConfig])
            } catch {
                #if DEBUG
                print("[Sync] CloudKit initialization failed: \(error). Falling back to local-only storage.")
                #endif
            }
        }

        let localConfig = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: [localConfig])
    }
}

class SubscriptionManager {
    private let context: ModelContext
    
    // initialize with a ModelContext
    init(context: ModelContext) {
        self.context = context
    }
    
    // fetch all subscriptions
    var subscriptions: [Subscription] {
        let fetchDescriptor = FetchDescriptor<Subscription>()
        return (try? context.fetch(fetchDescriptor)) ?? []
    }
    
    // computed property for unique categories
    var categories: [String] {
        let cleanedCategories = subscriptions.map { sub in
            let trimmed = sub.category?.trimmingCharacters(in: .whitespacesAndNewlines)
            return (trimmed?.isEmpty ?? true) ? "Uncategorized" : trimmed!
        }

        let uniqueCategories = Array(Set(cleanedCategories)).sorted()
        return ["All Subscriptions"] + uniqueCategories
    }
    
    // add a subscription
    func addSubscription(_ subscription: Subscription) {
        context.insert(subscription)
    }
    
    // delete a subscription
    func deleteSubscription(_ subscription: Subscription) {
        context.delete(subscription)
    }
}
