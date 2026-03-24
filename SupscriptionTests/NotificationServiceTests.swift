//
//  NotificationServiceTests.swift
//  SupscriptionTests
//
//  Created by Ricardo Flores on 3/22/26.
//

import XCTest
import UserNotifications
@testable import Supscription

final class NotificationServiceTests: XCTestCase {

    private let service = NotificationService.shared
    private let center = UNUserNotificationCenter.current()

    override func tearDown() async throws {
        // Clean up any pending notifications from tests
        center.removeAllPendingNotificationRequests()
        try await super.tearDown()
    }

    // MARK: - Helpers

    private func makeSubscription(
        name: String = "TestSub",
        cancelReminderDate: Date? = nil
    ) -> Subscription {
        Subscription(
            accountName: name,
            category: "Testing",
            price: 9.99,
            billingDate: nil,
            billingFrequency: BillingFrequency.monthly.rawValue,
            autoRenew: false,
            remindToCancel: true,
            cancelReminderDate: cancelReminderDate,
            lastModified: nil
        )
    }

    private func pendingRequests() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }

    // MARK: - Identifier Format

    func testCancelReminderIdentifier_matchesBetweenScheduleAndRemove() async throws {
        let sub = makeSubscription(
            name: "Netflix",
            cancelReminderDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        )

        let expectedIdentifier = "cancelReminder_\(sub.id.uuidString)"

        service.scheduleCancelReminder(for: sub)

        // Allow notification center to process
        try await Task.sleep(nanoseconds: 500_000_000)

        let pending = await pendingRequests()
        let match = pending.first { $0.identifier == expectedIdentifier }
        XCTAssertNotNil(match, "Scheduled notification should use identifier: \(expectedIdentifier)")

        // Now remove and verify it's gone
        service.removeNotification(for: sub)
        try await Task.sleep(nanoseconds: 500_000_000)

        let afterRemove = await pendingRequests()
        let stillThere = afterRemove.first { $0.identifier == expectedIdentifier }
        XCTAssertNil(stillThere, "Notification should be removed after removeNotification call")
    }

    // MARK: - Future Date Scheduling

    func testScheduleCancelReminder_futureDate_usesCalendarTrigger() async throws {
        let futureDate = Calendar.current.date(byAdding: .day, value: 14, to: Date())!
        let sub = makeSubscription(name: "Spotify", cancelReminderDate: futureDate)

        service.scheduleCancelReminder(for: sub)
        try await Task.sleep(nanoseconds: 500_000_000)

        let pending = await pendingRequests()
        let match = pending.first { $0.identifier == "cancelReminder_\(sub.id.uuidString)" }

        XCTAssertNotNil(match)
        XCTAssertTrue(match?.trigger is UNCalendarNotificationTrigger,
                       "Future date should use UNCalendarNotificationTrigger")
    }

    // MARK: - Past Date Scheduling

    func testScheduleCancelReminder_pastDate_usesTimeIntervalTrigger() async throws {
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let sub = makeSubscription(name: "Hulu", cancelReminderDate: pastDate)

        service.scheduleCancelReminder(for: sub)
        try await Task.sleep(nanoseconds: 500_000_000)

        let pending = await pendingRequests()
        let match = pending.first { $0.identifier == "cancelReminder_\(sub.id.uuidString)" }

        XCTAssertNotNil(match, "Past-due reminders should still schedule (fires in 10 seconds)")
        XCTAssertTrue(match?.trigger is UNTimeIntervalNotificationTrigger,
                       "Past date should use UNTimeIntervalNotificationTrigger")
    }

    // MARK: - Nil Reminder Date

    func testScheduleCancelReminder_nilDate_doesNotSchedule() async throws {
        let sub = makeSubscription(name: "NoDate", cancelReminderDate: nil)

        service.scheduleCancelReminder(for: sub)
        try await Task.sleep(nanoseconds: 500_000_000)

        let pending = await pendingRequests()
        let match = pending.first { $0.identifier == "cancelReminder_\(sub.id.uuidString)" }

        XCTAssertNil(match, "Should not schedule when cancelReminderDate is nil")
    }

    // MARK: - Notification Content

    func testScheduleCancelReminder_contentIncludesSubscriptionName() async throws {
        let futureDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        let sub = makeSubscription(name: "Adobe Creative Cloud", cancelReminderDate: futureDate)

        service.scheduleCancelReminder(for: sub)
        try await Task.sleep(nanoseconds: 500_000_000)

        let pending = await pendingRequests()
        let match = pending.first { $0.identifier == "cancelReminder_\(sub.id.uuidString)" }

        XCTAssertNotNil(match)
        XCTAssertEqual(match?.content.title, "Cancellation Reminder")
        XCTAssertTrue(match?.content.body.contains("Adobe Creative Cloud") ?? false,
                       "Notification body should include the subscription name")
        XCTAssertEqual(match?.content.threadIdentifier, "cancelReminder")
        XCTAssertEqual(match?.content.userInfo["subscriptionID"] as? String, sub.id.uuidString)
    }

    // MARK: - Remove Only Targets Specific Subscription

    func testRemoveNotification_doesNotAffectOtherSubscriptions() async throws {
        let futureDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let sub1 = makeSubscription(name: "Netflix", cancelReminderDate: futureDate)
        let sub2 = makeSubscription(name: "Spotify", cancelReminderDate: futureDate)

        service.scheduleCancelReminder(for: sub1)
        service.scheduleCancelReminder(for: sub2)
        try await Task.sleep(nanoseconds: 500_000_000)

        // Remove only sub1
        service.removeNotification(for: sub1)
        try await Task.sleep(nanoseconds: 500_000_000)

        let pending = await pendingRequests()
        let sub1Match = pending.first { $0.identifier == "cancelReminder_\(sub1.id.uuidString)" }
        let sub2Match = pending.first { $0.identifier == "cancelReminder_\(sub2.id.uuidString)" }

        XCTAssertNil(sub1Match, "sub1 notification should be removed")
        XCTAssertNotNil(sub2Match, "sub2 notification should still exist")
    }

    // MARK: - Update Reminder (Remove + Reschedule)

    func testUpdateReminderDate_removesOldAndSchedulesNew() async throws {
        let originalDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let sub = makeSubscription(name: "GitHub", cancelReminderDate: originalDate)

        service.scheduleCancelReminder(for: sub)
        try await Task.sleep(nanoseconds: 500_000_000)

        // Verify original is scheduled
        var pending = await pendingRequests()
        var match = pending.first { $0.identifier == "cancelReminder_\(sub.id.uuidString)" }
        XCTAssertNotNil(match, "Original reminder should be scheduled")

        // Update: remove old, change date, reschedule
        service.removeNotification(for: sub)
        let newDate = Calendar.current.date(byAdding: .day, value: 14, to: Date())!
        sub.cancelReminderDate = newDate
        service.scheduleCancelReminder(for: sub)
        try await Task.sleep(nanoseconds: 500_000_000)

        // Verify new one exists with updated trigger
        pending = await pendingRequests()
        match = pending.first { $0.identifier == "cancelReminder_\(sub.id.uuidString)" }
        XCTAssertNotNil(match, "Updated reminder should be scheduled")

        // Verify only one notification for this subscription
        let allForSub = pending.filter { $0.identifier == "cancelReminder_\(sub.id.uuidString)" }
        XCTAssertEqual(allForSub.count, 1, "Should only have one notification per subscription")
    }

    // MARK: - Future: Permission Denied
    // NOTE: Testing permission-denied behavior requires mocking UNUserNotificationCenter,
    // which would require a protocol abstraction in production code. Flagged for v2.0
    // when NotificationService is refactored to accept a notification center dependency.
}
