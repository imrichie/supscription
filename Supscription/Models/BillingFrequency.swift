//
//  BillingFrequency.swift
//  Supscription
//
//  Created by Ricardo Flores on 3/26/25.
//

import Foundation

enum BillingFrequency: String, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case yearly = "Yearly"
    
    var id: String { rawValue }
}

extension BillingFrequency {
    func nextBillingDate(from billingDate: Date) -> Date {
        var nextDate = billingDate
        let now = Date()
        let calendar = Calendar.current

        while nextDate < now {
            switch self {
            case .daily:
                nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
            case .weekly:
                nextDate = calendar.date(byAdding: .weekOfYear, value: 1, to: nextDate) ?? nextDate
            case .monthly:
                nextDate = calendar.date(byAdding: .month, value: 1, to: nextDate) ?? nextDate
            case .quarterly:
                nextDate = calendar.date(byAdding: .month, value: 3, to: nextDate) ?? nextDate
            case .yearly:
                nextDate = calendar.date(byAdding: .year, value: 1, to: nextDate) ?? nextDate
            case .none:
                return billingDate
            }
        }

        return nextDate
    }
}
