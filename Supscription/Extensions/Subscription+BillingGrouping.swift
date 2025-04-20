//
//  Subscription+BillingGrouping.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/8/25.
//

import Foundation

enum BillingSection: String, CaseIterable {
    case past = "Past"
    case today = "Today"
    case next7Days = "Next 7 Days"
    case laterThisMonth = "Later This Month"
    case future = "Upcoming"
    case noDate = "No Billing Date"
    case nextYear = "Next Year"
}

extension Array where Element == Subscription {
    func groupedByBillingSection(reference: Date = Date()) -> [BillingSection: [Subscription]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: reference)

        return Dictionary(grouping: self) { subscription in
            guard let billingDate = subscription.nextBillingDate else {
                return .noDate
            }

            if billingDate < today {
                return .past
            } else if calendar.isDateInToday(billingDate) {
                return .today
            } else if let next7 = calendar.date(byAdding: .day, value: 7, to: today),
                      billingDate <= next7 {
                return .next7Days
            } else if calendar.isDate(billingDate, equalTo: today, toGranularity: .month) {
                return .laterThisMonth
            } else if calendar.component(.year, from: billingDate) > calendar.component(.year, from: today) {
                return .nextYear
            } else {
                return .future
            }
        }
    }
}
