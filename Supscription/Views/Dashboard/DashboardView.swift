//
//  DashboardView.swift
//  Supscription
//
//  Created by Richie Flores on 3/14/26.
//

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    let subscriptions: [Subscription]
    @Binding var selectedDestination: SidebarDestination
    @Binding var selectedSubscription: Subscription?

    @StateObject private var viewModel: DashboardViewModel

    init(
        subscriptions: [Subscription],
        selectedDestination: Binding<SidebarDestination>,
        selectedSubscription: Binding<Subscription?>
    ) {
        self.subscriptions = subscriptions
        self._selectedDestination = selectedDestination
        self._selectedSubscription = selectedSubscription
        self._viewModel = StateObject(wrappedValue: DashboardViewModel(subscriptions: subscriptions))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ROW 1: Scorecards
                scorecardsRow

                // ROW 2: Charts
                chartsSection

                // ROW 3: Upcoming Renewals
                renewalsSection
            }
            .padding(28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Row 1: Scorecards

    private var scorecardsRow: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 4), spacing: 14) {
            ScoreCardView(
                title: "Monthly Spend",
                value: viewModel.formattedCurrency(viewModel.monthlyTotal),
                subtitle: "\(viewModel.activeCount) subscriptions",
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

    // MARK: - Row 2: Charts
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Spending")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            HStack(alignment: .top, spacing: 14) {
                monthlyTrendCard
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                categoryCard
                    .frame(maxWidth: 350, maxHeight: .infinity)
            }
            .frame(height: 220)
        }
    }

    private var monthlyTrendCard: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Monthly Trend")
                .font(.headline)

            Text("Spending over 6 months")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 4)

            let hasSpend = viewModel.monthlySeries.contains { $0.amount > 0 }

            if hasSpend {
                Chart(viewModel.monthlySeries) { item in
                    BarMark(
                        x: .value("Month", item.month),
                        y: .value("Amount", item.amount)
                    )
                    .foregroundStyle(
                        item.month == viewModel.currentMonthAbbrev
                            ? Color.blue
                            : Color.blue.opacity(0.25)
                    )
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                    }
                }
                .chartYAxis(.hidden)
                .chartYScale(domain: 0...(viewModel.monthlySeries.map(\.amount).max() ?? 1) * 1.2)
            } else {
                Text("Add subscriptions to see trends")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separatorColor), lineWidth: 0.5)
        )
    }

    private var categoryCard: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("By Category")
                .font(.headline)

            Text("Current month")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 4)

            if viewModel.categoryBreakdown.isEmpty {
                Text("No categories yet")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let maxTotal = viewModel.categoryBreakdown.first?.total ?? 1
                let opacities: [Double] = [1.0, 0.75, 0.55, 0.38, 0.15]

                VStack(spacing: 8) {
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

                            GeometryReader { barGeo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(Color(.separatorColor))
                                        .frame(height: 7)

                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(Color.blue.opacity(opacities[min(index, opacities.count - 1)]))
                                        .frame(
                                            width: maxTotal > 0
                                                ? barGeo.size.width * (item.total / maxTotal)
                                                : 0,
                                            height: 7
                                        )
                                }
                            }
                            .frame(height: 7)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(.separatorColor), lineWidth: 0.5)
        )
    }

    // MARK: - Row 3: Upcoming Renewals

    private var renewalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Upcoming Renewals")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

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
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                Divider()

                if viewModel.upcomingRenewals.isEmpty {
                    // Empty state
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
                } else {
                    // Renewal rows
                    ForEach(Array(viewModel.visibleRenewals.enumerated()), id: \.element.id) { index, subscription in
                        if index > 0 {
                            Divider()
                                .padding(.leading, 20)
                        }

                        UpcomingRenewalRow(
                            subscription: subscription,
                            onFlagToggle: { toggleReminder(for: subscription) },
                            onOpenWebsite: { openWebsite(for: subscription) },
                            onSelectSubscription: { selectSubscription(subscription) }
                        )
                    }

                    // Show More / Show Less
                    if viewModel.upcomingRenewals.count > 5 {
                        Divider()
                            .padding(.leading, 20)

                        Button(viewModel.isExpanded
                               ? "Show Less"
                               : "Show More (\(viewModel.upcomingRenewals.count - 5) more)") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.isExpanded.toggle()
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .buttonStyle(.plain)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(.separatorColor), lineWidth: 0.5)
            )
        }
    }

    // MARK: - Actions

    private func toggleReminder(for subscription: Subscription) {
        subscription.remindToCancel.toggle()
        try? modelContext.save()

        if subscription.remindToCancel {
            if subscription.cancelReminderDate != nil {
                NotificationService.shared.scheduleCancelReminder(for: subscription)
            }
        } else {
            NotificationService.shared.removeNotification(for: subscription)
        }
    }

    private func openWebsite(for subscription: Subscription) {
        guard let urlString = subscription.accountURL,
              let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    private func selectSubscription(_ subscription: Subscription) {
        selectedDestination = .subscriptions(category: AppConstants.Category.all)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedSubscription = subscription
        }
    }
}
