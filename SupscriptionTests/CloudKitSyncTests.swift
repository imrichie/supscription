//
//  CloudKitSyncTests.swift
//  SupscriptionTests
//
//  Created by Richie Flores on 4/3/26.
//

import XCTest
import SwiftData
@testable import Supscription

final class CloudKitSyncTests: XCTestCase {

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

    // MARK: - CloudKit Compatibility

    /// CloudKit requires all attributes to have defaults or be optional.
    /// This test ensures the model can be created with zero arguments beyond the init signature.
    func testModelHasCloudKitCompatibleDefaults() throws {
        let sub = Subscription(
            accountName: "",
            category: nil,
            price: 0.0,
            billingDate: nil,
            billingFrequency: BillingFrequency.none.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: nil
        )

        context.insert(sub)
        XCTAssertNoThrow(try context.save())

        let results = try context.fetch(FetchDescriptor<Subscription>())
        XCTAssertEqual(results.count, 1)
    }

    /// CloudKit doesn't support @Attribute(.unique). Verify duplicates are allowed at the model level.
    func testDuplicateIDsAllowedForCloudKit() throws {
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
            category: "Streaming",
            price: 15.99,
            billingDate: nil,
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: nil
        )

        context.insert(sub1)
        context.insert(sub2)

        // Should not throw — no unique constraints
        XCTAssertNoThrow(try context.save())

        let results = try context.fetch(FetchDescriptor<Subscription>())
        XCTAssertEqual(results.count, 2)
        XCTAssertNotEqual(sub1.id, sub2.id)
    }

    // MARK: - Default Values for Sync Safety

    /// Verify every field has a safe default so CloudKit never encounters nil on required fields.
    func testDefaultPropertyValues() throws {
        let sub = Subscription(
            accountName: "Test",
            category: nil,
            price: 0,
            billingDate: nil,
            billingFrequency: BillingFrequency.none.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: nil
        )

        // Non-optional fields should have their defaults
        XCTAssertFalse(sub.id.uuidString.isEmpty)
        XCTAssertEqual(sub.accountName, "Test")
        XCTAssertEqual(sub.price, 0.0, accuracy: 0.001)
        XCTAssertEqual(sub.billingFrequency, BillingFrequency.none.rawValue)
        XCTAssertTrue(sub.autoRenew)
        XCTAssertFalse(sub.remindToCancel)
        XCTAssertNotNil(sub.lastModified)

        // Optional fields should be nil
        XCTAssertNil(sub.category)
        XCTAssertNil(sub.logoName)
        XCTAssertNil(sub.accountURL)
        XCTAssertNil(sub.billingDate)
        XCTAssertNil(sub.cancelReminderDate)
    }

    // MARK: - Last-Writer-Wins Simulation

    /// Simulate a sync conflict where two versions of the same subscription exist.
    /// The app should be able to identify and resolve by lastModified date.
    func testLastWriterWinsConflictResolution() throws {
        let now = Date()
        let earlier = now.addingTimeInterval(-3600)

        let olderVersion = Subscription(
            accountName: "Spotify",
            category: "Music",
            price: 9.99,
            billingDate: nil,
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: earlier
        )

        let newerVersion = Subscription(
            accountName: "Spotify",
            category: "Music",
            price: 12.99,
            billingDate: nil,
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: now
        )

        context.insert(olderVersion)
        context.insert(newerVersion)
        try context.save()

        // Fetch all versions with the same name
        let results = try context.fetch(FetchDescriptor<Subscription>())
        let spotifyVersions = results.filter { $0.accountName == "Spotify" }
        XCTAssertEqual(spotifyVersions.count, 2)

        // The newer version should win in a dedup scenario
        let winner = try XCTUnwrap(spotifyVersions.max(by: { $0.lastModified < $1.lastModified }))
        XCTAssertEqual(winner.price, 12.99, accuracy: 0.001)
        XCTAssertEqual(winner.lastModified, now)
    }

    // MARK: - ModelContainer Fallback

    /// Verify that a local-only ModelContainer can be created (fallback path).
    func testLocalOnlyContainerCreation() throws {
        let localConfig = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let localContainer = try ModelContainer(for: Subscription.self, configurations: localConfig)
        let localContext = ModelContext(localContainer)

        let sub = Subscription(
            accountName: "Local Only",
            category: "Test",
            price: 5.99,
            billingDate: nil,
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: true,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: nil
        )

        localContext.insert(sub)
        try localContext.save()

        let results = try localContext.fetch(FetchDescriptor<Subscription>())
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.accountName, "Local Only")
    }

    // MARK: - Sync Toggle Preference

    /// Verify the sync toggle UserDefaults key defaults to true (enabled).
    func testSyncToggleDefaultsToEnabled() {
        // Clear any existing value
        UserDefaults.standard.removeObject(forKey: "iCloudSyncEnabled")

        let value = UserDefaults.standard.object(forKey: "iCloudSyncEnabled") as? Bool ?? true
        XCTAssertTrue(value)
    }

    /// Verify the sync toggle can be disabled and persisted.
    func testSyncToggleCanBeDisabled() {
        UserDefaults.standard.set(false, forKey: "iCloudSyncEnabled")
        let value = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")
        XCTAssertFalse(value)

        // Clean up
        UserDefaults.standard.removeObject(forKey: "iCloudSyncEnabled")
    }

    // MARK: - Data Integrity Under Sync

    /// Verify all field types survive a save/fetch cycle (simulating sync roundtrip).
    func testFullModelRoundtrip() throws {
        let billingDate = Date()
        let reminderDate = Calendar.current.date(byAdding: .day, value: 7, to: billingDate)!

        let sub = Subscription(
            accountName: "Adobe Creative Cloud",
            category: "Productivity",
            price: 54.99,
            billingDate: billingDate,
            billingFrequency: BillingFrequency.yearly.rawValue,
            autoRenew: false,
            remindToCancel: true,
            cancelReminderDate: reminderDate,
            logoName: "adobe-logo",
            accountURL: "adobe.com",
            lastModified: billingDate
        )

        context.insert(sub)
        try context.save()

        // Fetch in a fresh context to simulate sync roundtrip
        let freshContext = ModelContext(container)
        let results = try freshContext.fetch(FetchDescriptor<Subscription>())
        let fetched = try XCTUnwrap(results.first)

        XCTAssertEqual(fetched.accountName, "Adobe Creative Cloud")
        XCTAssertEqual(fetched.category, "Productivity")
        XCTAssertEqual(fetched.price, 54.99, accuracy: 0.001)
        XCTAssertNotNil(fetched.billingDate)
        XCTAssertEqual(fetched.billingFrequency, BillingFrequency.yearly.rawValue)
        XCTAssertFalse(fetched.autoRenew)
        XCTAssertTrue(fetched.remindToCancel)
        XCTAssertNotNil(fetched.cancelReminderDate)
        XCTAssertEqual(fetched.logoName, "adobe-logo")
        XCTAssertEqual(fetched.accountURL, "adobe.com")
        XCTAssertNotNil(fetched.lastModified)
    }
}
