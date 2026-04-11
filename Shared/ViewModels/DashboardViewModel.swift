//
//  DashboardViewModel.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/16/26.
//

import Foundation
import Combine

// MARK: - Chart Data Models

struct MonthlyDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

struct CategoryDataPoint: Identifiable {
    let id = UUID()
    let category: String
    let total: Double
}

// MARK: - ViewModel

class DashboardViewModel: ObservableObject {
    var subscriptions: [Subscription] {
        didSet { objectWillChange.send() }
    }

    @Published var isExpanded: Bool = false

    init(subscriptions: [Subscription]) {
        self.subscriptions = subscriptions
    }

    // MARK: - Normalization

    func monthlyEquivalent(_ sub: Subscription) -> Double {
        guard let frequency = BillingFrequency(rawValue: sub.billingFrequency) else { return 0 }
        switch frequency {
        case .daily:      return sub.price * 30.44
        case .weekly:     return sub.price * 4.33
        case .monthly:    return sub.price
        case .quarterly:  return sub.price / 3
        case .yearly:     return sub.price / 12
        case .none:       return 0
        }
    }

    // MARK: - Scorecards

    var monthlyTotal: Double {
        subscriptions.reduce(0) { $0 + monthlyEquivalent($1) }
    }

    var yearlyTotal: Double {
        monthlyTotal * 12
    }

    var activeCount: Int {
        subscriptions.count
    }

    var dueSoonCount: Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        guard let weekOut = calendar.date(byAdding: .day, value: 7, to: now) else { return 0 }
        return subscriptions.filter { sub in
            guard let date = sub.nextBillingDate else { return false }
            let start = calendar.startOfDay(for: date)
            return start >= now && start <= weekOut
        }.count
    }

    var remindToCancelCount: Int {
        subscriptions.filter { $0.remindToCancel }.count
    }

    // MARK: - Monthly Trend (last 6 months)

    var monthlySeries: [MonthlyDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        var result: [MonthlyDataPoint] = []

        for offset in stride(from: -5, through: 0, by: 1) {
            guard let monthDate = calendar.date(byAdding: .month, value: offset, to: now) else { continue }
            let monthLabel = formatter.string(from: monthDate)
            let monthComponents = calendar.dateComponents([.year, .month], from: monthDate)

            var total: Double = 0
            for sub in subscriptions {
                guard let billingDate = sub.billingDate,
                      let frequency = BillingFrequency(rawValue: sub.billingFrequency),
                      frequency != .none else { continue }

                if hasBillingEvent(billingDate: billingDate, frequency: frequency, inMonth: monthComponents, calendar: calendar) {
                    total += sub.price
                }
            }

            result.append(MonthlyDataPoint(month: monthLabel, amount: total))
        }

        return result
    }

    private func hasBillingEvent(billingDate: Date, frequency: BillingFrequency, inMonth target: DateComponents, calendar: Calendar) -> Bool {
        guard let targetYear = target.year, let targetMonth = target.month else { return false }

        let billingComponents = calendar.dateComponents([.year, .month], from: billingDate)
        guard let billingYear = billingComponents.year, let billingMonth = billingComponents.month else { return false }

        switch frequency {
        case .daily, .weekly, .monthly:
            return true
        case .quarterly:
            let diff = (targetYear * 12 + targetMonth) - (billingYear * 12 + billingMonth)
            return diff >= 0 && diff % 3 == 0
        case .yearly:
            return targetMonth == billingMonth
        case .none:
            return false
        }
    }

    // MARK: - Category Breakdown

    var categoryBreakdown: [CategoryDataPoint] {
        var totals: [String: Double] = [:]
        for sub in subscriptions {
            let key = sub.category?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? sub.category! : "Uncategorized"
            totals[key, default: 0] += monthlyEquivalent(sub)
        }

        let sorted = totals
            .map { CategoryDataPoint(category: $0.key, total: $0.value) }
            .sorted { $0.total > $1.total }

        let filtered = sorted.filter { $0.total > 0 }

        if filtered.count <= 5 {
            return filtered
        }

        let top4 = Array(filtered.prefix(4))
        let otherTotal = filtered.dropFirst(4).reduce(0) { $0 + $1.total }
        return top4 + [CategoryDataPoint(category: "Other", total: otherTotal)]
    }

    // MARK: - Upcoming Renewals

    var upcomingRenewals: [Subscription] {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        guard let thirtyDaysOut = calendar.date(byAdding: .day, value: 30, to: now) else { return [] }

        return subscriptions
            .filter { sub in
                guard let date = sub.nextBillingDate else { return false }
                let start = calendar.startOfDay(for: date)
                return start >= now && start <= thirtyDaysOut
            }
            .sorted { ($0.nextBillingDate ?? .distantFuture) < ($1.nextBillingDate ?? .distantFuture) }
    }

    var visibleRenewals: [Subscription] {
        if isExpanded {
            return upcomingRenewals
        } else {
            return Array(upcomingRenewals.prefix(5))
        }
    }

    // MARK: - Formatting

    func formattedCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
