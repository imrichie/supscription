//
//  DashboardTab.swift
//  Supscription iOS
//
//  Created by Richie Flores on 4/5/26.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardTab: View {
    @Query private var subscriptions: [Subscription]

    var body: some View {
        NavigationStack {
            Group {
                if subscriptions.isEmpty {
                    emptyState
                } else {
                    DashboardContentView(subscriptions: subscriptions)
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: Subscription.self) { subscription in
                SubscriptionDetailView(subscription: subscription)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "No Subscriptions Yet",
            systemImage: "chart.bar.doc.horizontal",
            description: Text("Add your first subscription to see spending insights, trends, and upcoming renewals.")
        )
    }
}

// MARK: - Dashboard Content

private struct DashboardContentView: View {
    let subscriptions: [Subscription]

    @StateObject private var viewModel: DashboardViewModel

    init(subscriptions: [Subscription]) {
        self.subscriptions = subscriptions
        _viewModel = StateObject(wrappedValue: DashboardViewModel(subscriptions: subscriptions))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                scorecardsGrid
                monthlyTrendSection
                categorySection
                renewalsSection
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .onChange(of: subscriptions) { _, newValue in
            viewModel.subscriptions = newValue
        }
    }

    // MARK: - Section 1: Scorecards

    private var scorecardsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ScoreCardView(
                title: "Monthly Spend",
                value: viewModel.formattedCurrency(viewModel.monthlyTotal),
                subtitle: "\(viewModel.activeCount) subscription\(viewModel.activeCount == 1 ? "" : "s")",
                systemImage: "creditcard.fill",
                cardColor: .blue
            )

            ScoreCardView(
                title: "Yearly Spend",
                value: viewModel.formattedCurrency(viewModel.yearlyTotal),
                subtitle: "Projected total",
                systemImage: "calendar",
                cardColor: .orange
            )

            ScoreCardView(
                title: "Due This Week",
                value: "\(viewModel.dueSoonCount)",
                subtitle: viewModel.dueSoonCount == 1 ? "Renewal upcoming" : "Renewals upcoming",
                systemImage: "bell.fill",
                cardColor: .green
            )

            ScoreCardView(
                title: "Active Subs",
                value: "\(viewModel.activeCount)",
                subtitle: viewModel.remindToCancelCount > 0
                    ? "\(viewModel.remindToCancelCount) flagged to cancel"
                    : "All active",
                systemImage: "square.grid.2x2.fill",
                cardColor: .purple
            )
        }
    }

    // MARK: - Section 2: Monthly Trend

    private var monthlyTrendSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader("Spending")

            VStack(alignment: .leading, spacing: 4) {
                Text("Monthly Trend")
                    .font(.headline)

                Text("Spending over 6 months")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                let hasSpend = viewModel.monthlySeries.contains { $0.amount > 0 }

                if hasSpend {
                    monthlyTrendChart
                        .frame(height: 180)
                        .padding(.top, 8)
                } else {
                    Text("Add subscriptions with billing dates to see trends")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, minHeight: 100)
                }
            }
            .padding(16)
            .background(cardBackground)
        }
    }

    private var monthlyTrendChart: some View {
        let seriesCount = viewModel.monthlySeries.count

        return Chart(Array(viewModel.monthlySeries.enumerated()), id: \.element.id) { index, item in
            let barOpacity = seriesCount > 1
                ? 0.25 + 0.75 * (Double(index) / Double(seriesCount - 1))
                : 1.0

            BarMark(
                x: .value("Month", item.month),
                y: .value("Amount", item.amount)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.blue.opacity(barOpacity), Color.blue.opacity(barOpacity * 0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                    .foregroundStyle(.separator)
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text("$\(Int(amount))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .chartYScale(domain: 0...(viewModel.monthlySeries.map(\.amount).max() ?? 1) * 1.2)
    }

    // MARK: - Section 3: By Category

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("By Category")
                .font(.headline)

            Text("Monthly breakdown")
                .font(.caption)
                .foregroundStyle(.secondary)

            if viewModel.categoryBreakdown.isEmpty {
                Text("No categories yet")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, minHeight: 60)
            } else {
                categoryRows
                    .padding(.top, 8)
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var categoryRows: some View {
        let maxTotal = viewModel.categoryBreakdown.first?.total ?? 1
        let rankColors: [Color] = [.blue, .purple, .orange, .teal, .gray]

        return VStack(spacing: 10) {
            ForEach(Array(viewModel.categoryBreakdown.enumerated()), id: \.element.id) { index, item in
                VStack(spacing: 4) {
                    HStack {
                        Text(item.category)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Text(viewModel.formattedCurrency(item.total))
                            .font(.caption.weight(.bold))
                            .lineLimit(1)
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(.quaternary)
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(rankColors[min(index, rankColors.count - 1)])
                                .frame(
                                    width: maxTotal > 0
                                        ? geo.size.width * (item.total / maxTotal)
                                        : 0,
                                    height: 6
                                )
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
    }

    // MARK: - Section 4: Upcoming Renewals

    private var renewalsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionHeader("Upcoming Renewals")

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Next 30 Days")
                        .font(.headline)
                    Spacer()
                    if !viewModel.upcomingRenewals.isEmpty {
                        Text("\(viewModel.upcomingRenewals.count) total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

                Divider()

                if viewModel.upcomingRenewals.isEmpty {
                    renewalsEmptyState
                } else {
                    renewalsList
                }
            }
            .background(cardBackground)
        }
    }

    private var renewalsEmptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No renewals in the next 30 days")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }

    private var renewalsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.visibleRenewals.enumerated()), id: \.element.id) { index, subscription in
                if index > 0 {
                    Divider()
                        .padding(.leading, 62)
                }

                NavigationLink(value: subscription) {
                    UpcomingRenewalRow(subscription: subscription)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
            }

            // Show More / Show Less
            if viewModel.upcomingRenewals.count > 5 {
                Divider()
                    .padding(.leading, 16)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.isExpanded.toggle()
                    }
                } label: {
                    Text(viewModel.isExpanded
                         ? "Show Less"
                         : "Show All (\(viewModel.upcomingRenewals.count - 5) more)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
        }
    }

    // MARK: - Shared Components

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(.background)
            .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}
