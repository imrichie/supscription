//
//  DashboardView.swift
//  Supscription
//
//  Created by Richie Flores on 3/14/26.
//

import SwiftUI

struct DashboardView: View {
    let subscriptions: [Subscription]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // MARK: - Computed Stats

    /// Normalizes a subscription's price to a monthly equivalent
    private func monthlyEquivalent(_ sub: Subscription) -> Double {
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

    private var totalMonthlyCost: Double {
        subscriptions.reduce(0) { $0 + monthlyEquivalent($1) }
    }

    private var totalAnnualCost: Double {
        totalMonthlyCost * 12
    }

    private var activeCount: Int {
        subscriptions.count
    }

    private var mostExpensive: Subscription? {
        subscriptions.max(by: { monthlyEquivalent($0) < monthlyEquivalent($1) })
    }

    private var upcomingRenewal: Subscription? {
        subscriptions
            .filter { $0.nextBillingDate != nil }
            .min(by: { $0.nextBillingDate! < $1.nextBillingDate! })
    }

    private var categoryTotals: [(name: String, monthlyTotal: Double)] {
        var totals: [String: Double] = [:]
        for sub in subscriptions {
            let key = sub.displayCategory
            totals[key, default: 0] += monthlyEquivalent(sub)
        }
        return totals
            .map { (name: $0.key, monthlyTotal: $0.value) }
            .sorted { $0.monthlyTotal > $1.monthlyTotal }
    }

    // MARK: - Formatting Helpers

    private func formatted(cost: Double) -> String {
        String(format: "$%.2f", cost)
    }

    private func renewalSubtitle(for sub: Subscription) -> String {
        guard let date = sub.nextBillingDate else { return "" }
        return date.formattedMedium()
    }

    // MARK: - View

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Section header
                Text("Overview")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)

                // Stat cards grid
                LazyVGrid(columns: columns, spacing: 16) {
                    DashboardStatCard(
                        title: "Total Monthly Cost",
                        value: formatted(cost: totalMonthlyCost),
                        icon: "calendar",
                        accentColor: .blue
                    )

                    DashboardStatCard(
                        title: "Total Annual Cost",
                        value: formatted(cost: totalAnnualCost),
                        icon: "chart.line.uptrend.xyaxis",
                        accentColor: .indigo
                    )

                    DashboardStatCard(
                        title: "Active Subscriptions",
                        value: "\(activeCount)",
                        icon: "checkmark.seal.fill",
                        accentColor: .teal
                    )

                    DashboardStatCard(
                        title: "Most Expensive",
                        value: mostExpensive.map { formatted(cost: monthlyEquivalent($0)) } ?? "—",
                        subtitle: mostExpensive?.accountName,
                        icon: "dollarsign.circle.fill",
                        accentColor: .orange
                    )

                    DashboardStatCard(
                        title: "Upcoming Renewal",
                        value: upcomingRenewal?.accountName ?? "—",
                        subtitle: upcomingRenewal.map { renewalSubtitle(for: $0) },
                        icon: "bell.fill",
                        accentColor: .pink
                    )
                }

                // Category breakdown
                Text("Spending Breakdown")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                DashboardCategoryCard(categoryTotals: categoryTotals)
            }
            .padding(24)
            .frame(maxWidth: 900)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
