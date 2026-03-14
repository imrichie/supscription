//
//  DashboardCategoryCard.swift
//  Supscription
//
//  Created by Richie Flores on 3/14/26.
//

import SwiftUI

struct DashboardCategoryCard: View {
    let categoryTotals: [(name: String, monthlyTotal: Double)]

    private var grandTotal: Double {
        categoryTotals.reduce(0) { $0 + $1.monthlyTotal }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.purple)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Cost by Category")
                        .font(.headline.weight(.semibold))
                    Text("Monthly estimate")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            if categoryTotals.isEmpty {
                Text("No categories yet")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 10) {
                    ForEach(categoryTotals, id: \.name) { item in
                        HStack(spacing: 10) {
                            Text(item.name)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .lineLimit(1)

                            Spacer()

                            // Progress bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(Color.purple.opacity(0.1))
                                        .frame(height: 6)
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(Color.purple.opacity(0.6))
                                        .frame(
                                            width: grandTotal > 0
                                                ? geo.size.width * (item.monthlyTotal / grandTotal)
                                                : 0,
                                            height: 6
                                        )
                                }
                                .frame(height: 6)
                                .frame(maxHeight: .infinity, alignment: .center)
                            }
                            .frame(width: 80, height: 16)

                            Text(String(format: "$%.2f", item.monthlyTotal))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .frame(minWidth: 60, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
        )
    }
}
