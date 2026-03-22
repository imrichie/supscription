//
//  SubscriptionModelTests.swift
//  SupscriptionTests
//
//  Created by Richie Flores on 3/21/26.
//

import XCTest
import SwiftData
@testable import Supscription

final class SubscriptionModelTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Subscription.self, configurations: config)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Test Create and Save

    func testCreateAndSave() throws {
        let sub = Subscription(
            accountName: "Netflix",
            category: "Streaming",
            price: 15.99,
            billingDate: Date(),
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            logoName: "netflix-logo",
            accountURL: "netflix.com",
            lastModified: nil
        )

        context.insert(sub)
        try context.save()

        let descriptor = FetchDescriptor<Subscription>()
        let results = try context.fetch(descriptor)

        XCTAssertEqual(results.count, 1)

        let fetched = try XCTUnwrap(results.first)
        XCTAssertEqual(fetched.accountName, "Netflix")
        XCTAssertEqual(fetched.category, "Streaming")
        XCTAssertEqual(fetched.price, 15.99, accuracy: 0.001)
        XCTAssertEqual(fetched.billingFrequency, "Monthly")
        XCTAssertTrue(fetched.autoRenew)
        XCTAssertFalse(fetched.remindToCancel)
        XCTAssertNil(fetched.cancelReminderDate)
        XCTAssertEqual(fetched.logoName, "netflix-logo")
        XCTAssertEqual(fetched.accountURL, "netflix.com")
    }

    // MARK: - Test Fetch by ID

    func testFetchByID() throws {
        let sub = Subscription(
            accountName: "Spotify",
            category: "Music",
            price: 10.99,
            billingDate: nil,
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: nil
        )

        context.insert(sub)
        try context.save()

        let targetID = sub.id
        let predicate = #Predicate<Subscription> { $0.id == targetID }
        let descriptor = FetchDescriptor<Subscription>(predicate: predicate)
        let results = try context.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.accountName, "Spotify")
    }

    // MARK: - Test Update Field

    func testUpdateField() throws {
        let sub = Subscription(
            accountName: "Hulu",
            category: "Streaming",
            price: 7.99,
            billingDate: nil,
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: false,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: nil
        )

        context.insert(sub)
        try context.save()

        sub.price = 17.99
        sub.accountName = "Hulu Premium"
        sub.lastModified = Date()
        try context.save()

        let targetID = sub.id
        let predicate = #Predicate<Subscription> { $0.id == targetID }
        let descriptor = FetchDescriptor<Subscription>(predicate: predicate)
        let results = try context.fetch(descriptor)

        let fetched = try XCTUnwrap(results.first)
        XCTAssertEqual(fetched.accountName, "Hulu Premium")
        XCTAssertEqual(fetched.price, 17.99, accuracy: 0.001)
    }

    // MARK: - Test Delete

    func testDelete() throws {
        let sub = Subscription(
            accountName: "Apple TV+",
            category: "Streaming",
            price: 9.99,
            billingDate: nil,
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: nil
        )

        context.insert(sub)
        try context.save()

        let beforeDelete = try context.fetch(FetchDescriptor<Subscription>())
        XCTAssertEqual(beforeDelete.count, 1)

        context.delete(sub)
        try context.save()

        let afterDelete = try context.fetch(FetchDescriptor<Subscription>())
        XCTAssertEqual(afterDelete.count, 0)
    }

    // MARK: - Test Create with Nil Optionals

    func testCreateWithNilOptionals() throws {
        let sub = Subscription(
            accountName: "Mystery Service",
            category: nil,
            price: 0.0,
            billingDate: nil,
            billingFrequency: BillingFrequency.none.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            logoName: nil,
            accountURL: nil,
            lastModified: nil
        )

        context.insert(sub)
        try context.save()

        let results = try context.fetch(FetchDescriptor<Subscription>())
        let fetched = try XCTUnwrap(results.first)

        XCTAssertEqual(fetched.accountName, "Mystery Service")
        XCTAssertNil(fetched.category)
        XCTAssertNil(fetched.logoName)
        XCTAssertNil(fetched.accountURL)
        XCTAssertNil(fetched.billingDate)
        XCTAssertNil(fetched.cancelReminderDate)
        XCTAssertEqual(fetched.price, 0.0, accuracy: 0.001)
        XCTAssertTrue(fetched.autoRenew)
        XCTAssertFalse(fetched.remindToCancel)
    }

    // MARK: - Test Duplicate Name Allowed at Model Level

    func testDuplicateNameAllowedAtModelLevel() throws {
        let sub1 = Subscription(
            accountName: "Netflix",
            category: "Streaming",
            price: 15.99,
            billingDate: nil,
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: nil
        )

        let sub2 = Subscription(
            accountName: "Netflix",
            category: "Entertainment",
            price: 22.99,
            billingDate: nil,
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: false,
            remindToCancel: true,
            cancelReminderDate: Date(),
            lastModified: nil
        )

        context.insert(sub1)
        context.insert(sub2)
        try context.save()

        let results = try context.fetch(FetchDescriptor<Subscription>())

        // Both save — duplicate detection is view-level, not model-level
        XCTAssertEqual(results.count, 2)

        let names = results.map(\.accountName)
        XCTAssertEqual(names.filter { $0 == "Netflix" }.count, 2)

        // Verify they have distinct IDs
        XCTAssertNotEqual(sub1.id, sub2.id)
    }
}
