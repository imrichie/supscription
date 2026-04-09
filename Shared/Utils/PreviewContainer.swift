//
//  PreviewContainer.swift
//  Supscription
//
//  Created by Richie Flores on 4/6/26.
//

#if DEBUG
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    let schema = Schema([Subscription.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    for subscription in sampleSubscriptions {
        container.mainContext.insert(subscription)
    }

    return container
}()
#endif
