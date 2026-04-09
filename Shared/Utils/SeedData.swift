//
//  SeedData.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/1/25.
//

#if DEBUG
import SwiftData

enum DebugSeeder {
    static func seedIfNeeded(in context: ModelContext) {
        let fetch = FetchDescriptor<Subscription>()
        if (try? context.fetch(fetch).isEmpty) == true {
            for subscription in sampleSubscriptions {
                context.insert(subscription)
            }
            try? context.save()
            print("🌱 Seeded sampleSubscriptions into ModelContext")
        }
    }
}
#endif
