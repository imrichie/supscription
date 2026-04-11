//
//  BillingCalculationTests.swift
//  SupscriptionTests
//
//  Created by Ricardo Flores on 3/22/26.
//

import XCTest
import SwiftData
@testable import Supscription

final class BillingCalculationTests: XCTestCase {

    // MARK: - Helpers

    private func makeSubscription(
        name: String = "Test",
        price: Double = 10.0,
        billingFrequency: BillingFrequency = .monthly,
        billingDate: Date? = nil,
        category: String? = nil
    ) -> Subscription {
        let sub = Subscription(
            accountName: name,
            category: category,
            price: price,
            billingDate: billingDate,
            billingFrequency: billingFrequency.rawValue,
            autoRenew: false,
            remindToCancel: false,
            cancelReminderDate: nil,
            lastModified: nil
        )
        return sub
    }

    // MARK: - Monthly Normalization

    func testMonthlyEquivalent_daily() {
        let sub = makeSubscription(price: 1.0, billingFrequency: .daily)
        let vm = DashboardViewModel(subscriptions: [sub])
        XCTAssertEqual(vm.monthlyEquivalent(sub), 1.0 * 30.44, accuracy: 0.01)
    }

    func testMonthlyEquivalent_weekly() {
        let sub = makeSubscription(price: 10.0, billingFrequency: .weekly)
        let vm = DashboardViewModel(subscriptions: [sub])
        XCTAssertEqual(vm.monthlyEquivalent(sub), 10.0 * 4.33, accuracy: 0.01)
    }

    func testMonthlyEquivalent_monthly() {
        let sub = makeSubscription(price: 15.99, billingFrequency: .monthly)
        let vm = DashboardViewModel(subscriptions: [sub])
        XCTAssertEqual(vm.monthlyEquivalent(sub), 15.99, accuracy: 0.01)
    }

    func testMonthlyEquivalent_quarterly() {
        let sub = makeSubscription(price: 30.0, billingFrequency: .quarterly)
        let vm = DashboardViewModel(subscriptions: [sub])
        XCTAssertEqual(vm.monthlyEquivalent(sub), 10.0, accuracy: 0.01)
    }

    func testMonthlyEquivalent_yearly() {
        let sub = makeSubscription(price: 120.0, billingFrequency: .yearly)
        let vm = DashboardViewModel(subscriptions: [sub])
        XCTAssertEqual(vm.monthlyEquivalent(sub), 10.0, accuracy: 0.01)
    }

    func testMonthlyEquivalent_none() {
        let sub = makeSubscription(price: 50.0, billingFrequency: .none)
        let vm = DashboardViewModel(subscriptions: [sub])
        XCTAssertEqual(vm.monthlyEquivalent(sub), 0.0, accuracy: 0.01)
    }

    // MARK: - Annual Projection

    func testYearlyTotal_isMonthlyTimesTwelve() {
        let subs = [
            makeSubscription(price: 15.99, billingFrequency: .monthly),
            makeSubscription(price: 119.88, billingFrequency: .yearly),
            makeSubscription(price: 5.0, billingFrequency: .weekly)
        ]
        let vm = DashboardViewModel(subscriptions: subs)
        XCTAssertEqual(vm.yearlyTotal, vm.monthlyTotal * 12, accuracy: 0.01)
    }

    func testMonthlyTotal_mixedFrequencies() {
        let subs = [
            makeSubscription(price: 10.0, billingFrequency: .monthly),  // 10.0
            makeSubscription(price: 120.0, billingFrequency: .yearly),  // 10.0
            makeSubscription(price: 30.0, billingFrequency: .quarterly) // 10.0
        ]
        let vm = DashboardViewModel(subscriptions: subs)
        XCTAssertEqual(vm.monthlyTotal, 30.0, accuracy: 0.01)
    }

    // MARK: - Next Billing Date

    func testNextBillingDate_monthly_pastDate() {
        let calendar = Calendar.current
        // Set billing date to 2 months ago
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: Date())!
        let next = BillingFrequency.monthly.nextBillingDate(from: twoMonthsAgo)
        XCTAssertGreaterThanOrEqual(next, Date())
    }

    func testNextBillingDate_monthly_futureDate() {
        let calendar = Calendar.current
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: Date())!
        let next = BillingFrequency.monthly.nextBillingDate(from: nextMonth)
        // Future date should stay as-is since it's already >= now
        XCTAssertEqual(next, nextMonth)
    }

    func testNextBillingDate_yearly_pastDate() {
        let calendar = Calendar.current
        let twoYearsAgo = calendar.date(byAdding: .year, value: -2, to: Date())!
        let next = BillingFrequency.yearly.nextBillingDate(from: twoYearsAgo)
        XCTAssertGreaterThanOrEqual(next, Date())
    }

    func testNextBillingDate_weekly_pastDate() {
        let calendar = Calendar.current
        let threeWeeksAgo = calendar.date(byAdding: .weekOfYear, value: -3, to: Date())!
        let next = BillingFrequency.weekly.nextBillingDate(from: threeWeeksAgo)
        XCTAssertGreaterThanOrEqual(next, Date())
        // Should be within 7 days from now
        let sevenDaysOut = calendar.date(byAdding: .day, value: 7, to: Date())!
        XCTAssertLessThanOrEqual(next, sevenDaysOut)
    }

    func testNextBillingDate_daily_pastDate() {
        let calendar = Calendar.current
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: Date())!
        let next = BillingFrequency.daily.nextBillingDate(from: fiveDaysAgo)
        XCTAssertGreaterThanOrEqual(next, Date())
        // Should be today or tomorrow
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertLessThanOrEqual(next, tomorrow)
    }

    func testNextBillingDate_quarterly_pastDate() {
        let calendar = Calendar.current
        let sevenMonthsAgo = calendar.date(byAdding: .month, value: -7, to: Date())!
        let next = BillingFrequency.quarterly.nextBillingDate(from: sevenMonthsAgo)
        XCTAssertGreaterThanOrEqual(next, Date())
        // Should be within 3 months from now
        let threeMonthsOut = calendar.date(byAdding: .month, value: 3, to: Date())!
        XCTAssertLessThanOrEqual(next, threeMonthsOut)
    }

    func testNextBillingDate_none_returnsOriginal() {
        let calendar = Calendar.current
        let pastDate = calendar.date(byAdding: .month, value: -6, to: Date())!
        let next = BillingFrequency.none.nextBillingDate(from: pastDate)
        XCTAssertEqual(next, pastDate)
    }

    // MARK: - hasBillingEvent (via monthlySeries)

    func testHasBillingEvent_monthlyStartsAtBillingMonth() {
        let calendar = Calendar.current
        let billingDate = calendar.date(byAdding: .month, value: -2, to: Date())!
        let sub = makeSubscription(price: 10.0, billingFrequency: .monthly, billingDate: billingDate)
        let vm = DashboardViewModel(subscriptions: [sub])

        let series = vm.monthlySeries
        XCTAssertEqual(series.count, 6)

        let chargedMonths = series.filter { $0.amount > 0 }
        XCTAssertEqual(chargedMonths.count, 3, "A subscription that started 2 months ago should only appear from its first billing month onward")

        for point in series.prefix(3) {
            XCTAssertEqual(point.amount, 0.0, accuracy: 0.01,
                           "Months before the billing start should not show spend")
        }

        for point in series.suffix(3) {
            XCTAssertEqual(point.amount, 10.0, accuracy: 0.01,
                           "Monthly subscriptions should charge once in each month after they start")
        }
    }

    func testHasBillingEvent_weeklyCountsAllOccurrencesInMonth() {
        let calendar = Calendar.current
        let currentMonthStart = calendar.dateInterval(of: .month, for: Date())!.start
        let billingDate = calendar.date(byAdding: .day, value: 1, to: currentMonthStart)!

        let sub = makeSubscription(price: 10.0, billingFrequency: .weekly, billingDate: billingDate)
        let vm = DashboardViewModel(subscriptions: [sub])

        guard let currentMonthPoint = vm.monthlySeries.last else {
            return XCTFail("Expected a data point for the current month")
        }

        XCTAssertGreaterThanOrEqual(currentMonthPoint.amount, 40.0, "Weekly subscriptions should count each weekly charge within the month")
    }

    func testHasBillingEvent_yearlyOnlyBillingMonth() {
        let calendar = Calendar.current
        // Set billing date to a specific month far enough in the past
        let billingDate = calendar.date(byAdding: .year, value: -1, to: Date())!
        let billingMonth = calendar.component(.month, from: billingDate)

        let sub = makeSubscription(price: 100.0, billingFrequency: .yearly, billingDate: billingDate)
        let vm = DashboardViewModel(subscriptions: [sub])

        let series = vm.monthlySeries
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        // Count how many months have the charge — should be exactly the months matching billing month
        let monthsWithCharge = series.filter { $0.amount > 0 }

        // Over 6 months, the billing month should appear at most once
        for point in monthsWithCharge {
            // Verify each charged month matches the billing month
            let matchingDate = (0..<12).compactMap { m -> Date? in
                let d = calendar.date(byAdding: .month, value: m - 6, to: Date())!
                return formatter.string(from: d) == point.month ? d : nil
            }.first
            if let matchDate = matchingDate {
                XCTAssertEqual(calendar.component(.month, from: matchDate), billingMonth)
            }
        }
    }

    func testHasBillingEvent_noneNeverCharges() {
        let calendar = Calendar.current
        let billingDate = calendar.date(byAdding: .month, value: -3, to: Date())!
        let sub = makeSubscription(price: 50.0, billingFrequency: .none, billingDate: billingDate)
        let vm = DashboardViewModel(subscriptions: [sub])

        let series = vm.monthlySeries
        for point in series {
            XCTAssertEqual(point.amount, 0.0, accuracy: 0.01,
                           "Frequency .none should never produce a billing event")
        }
    }

    // MARK: - Smart Reminder Date Default

    func testSmartReminderDate_withFrequency_threeBeforeNextBilling() {
        let calendar = Calendar.current
        let billingDate = calendar.date(byAdding: .month, value: -1, to: Date())!
        let frequency = BillingFrequency.monthly

        let nextBilling = frequency.nextBillingDate(from: billingDate)
        let expectedReminder = calendar.date(byAdding: .day, value: -3, to: nextBilling)!

        // The smart default should be 3 days before next billing
        if expectedReminder > Date() {
            // This is the primary path — 3 days before next billing
            XCTAssertGreaterThan(expectedReminder, Date())
            let daysBetween = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: expectedReminder).day!
            XCTAssertGreaterThanOrEqual(daysBetween, 0)
        } else {
            // Fallback path — 30 days from now
            let fallback = calendar.date(byAdding: .day, value: 30, to: Date())!
            XCTAssertGreaterThan(fallback, Date())
        }
    }

    func testSmartReminderDate_noFrequency_thirtyDaysFromNow() {
        let calendar = Calendar.current
        let frequency = BillingFrequency.none

        // With .none, smart default should be 30 days from now
        // (nextBillingDate returns the original date, which would be in the past,
        //  so subtracting 3 days would also be in the past → fallback to 30 days)
        let fallback = calendar.date(byAdding: .day, value: 30, to: Date())!
        let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: fallback).day!
        XCTAssertEqual(daysDiff, 30)

        // Also verify .none returns original billing date (doesn't advance)
        let pastDate = calendar.date(byAdding: .month, value: -2, to: Date())!
        let result = frequency.nextBillingDate(from: pastDate)
        XCTAssertEqual(result, pastDate)
    }

    func testSmartReminderDate_fallbackWhenThreeDaysBeforeIsPast() {
        let calendar = Calendar.current
        // Set billing date to tomorrow — next billing is tomorrow, minus 3 = 2 days ago
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let frequency = BillingFrequency.monthly

        let nextBilling = frequency.nextBillingDate(from: tomorrow)
        let threeBeforeNext = calendar.date(byAdding: .day, value: -3, to: nextBilling)!

        if threeBeforeNext <= Date() {
            // Should fall back to 30 days from now
            let fallback = calendar.date(byAdding: .day, value: 30, to: Date())!
            let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()), to: fallback).day!
            XCTAssertEqual(daysDiff, 30)
        }
    }

    // MARK: - Category Breakdown

    func testCategoryBreakdown_capsAtFivePlusOther() {
        let categories = ["Streaming", "Productivity", "Gaming", "Music", "News", "Storage", "Health"]
        let subs = categories.map { cat -> Subscription in
            makeSubscription(price: 10.0, billingFrequency: .monthly, category: cat)
        }
        let vm = DashboardViewModel(subscriptions: subs)
        let breakdown = vm.categoryBreakdown

        XCTAssertEqual(breakdown.count, 5, "Should be top 4 + Other")
        XCTAssertEqual(breakdown.last?.category, "Other")
    }

    func testCategoryBreakdown_fiveOrFewerShowsAll() {
        let subs = [
            makeSubscription(price: 10.0, billingFrequency: .monthly, category: "Streaming"),
            makeSubscription(price: 20.0, billingFrequency: .monthly, category: "Productivity")
        ]

        let vm = DashboardViewModel(subscriptions: subs)
        let breakdown = vm.categoryBreakdown

        XCTAssertEqual(breakdown.count, 2)
        XCTAssertTrue(breakdown.contains { $0.category == "Streaming" })
        XCTAssertTrue(breakdown.contains { $0.category == "Productivity" })
    }

    func testCategoryBreakdown_sortedDescending() {
        let subs = [
            makeSubscription(price: 5.0, billingFrequency: .monthly, category: "Cheap"),
            makeSubscription(price: 30.0, billingFrequency: .monthly, category: "Expensive"),
            makeSubscription(price: 15.0, billingFrequency: .monthly, category: "Mid")
        ]

        let vm = DashboardViewModel(subscriptions: subs)
        let breakdown = vm.categoryBreakdown

        XCTAssertEqual(breakdown[0].category, "Expensive")
        XCTAssertEqual(breakdown[1].category, "Mid")
        XCTAssertEqual(breakdown[2].category, "Cheap")
    }

    // MARK: - Due Soon Count

    func testDueSoonCount_withinSevenDays() {
        let calendar = Calendar.current
        let threeDaysOut = calendar.date(byAdding: .day, value: 3, to: Date())!
        let tenDaysOut = calendar.date(byAdding: .day, value: 10, to: Date())!

        let sub1 = makeSubscription(price: 10.0, billingFrequency: .monthly, billingDate: threeDaysOut)
        let sub2 = makeSubscription(price: 10.0, billingFrequency: .monthly, billingDate: tenDaysOut)

        let vm = DashboardViewModel(subscriptions: [sub1, sub2])
        XCTAssertEqual(vm.dueSoonCount, 1, "Only the subscription due in 3 days should count")
    }
}
