//
//  CategorySuggestionService.swift
//  Supscription
//
//  Created by Richie Flores on 3/29/26.
//

import Foundation
import FoundationModels

final class CategorySuggestionService {
    static let shared = CategorySuggestionService()
    private init() {}

    // MARK: - Prompt (versioned)

    private static let promptV1 = """
    You are a subscription categorizer. Given the name of a subscription service or company, \
    respond with exactly ONE word from this list that best describes the category:

    Streaming, Productivity, Gaming, Music, News, Storage, Utilities, Health, Finance, \
    Shopping, Education, Social, Communication, Food, Fitness, Entertainment, Developer

    Rules:
    - Respond with exactly one word from the list above, nothing else.
    - If the name is gibberish, random characters, or unrecognizable, respond with: Other
    - Do not explain your reasoning. Do not add punctuation.
    """

    // MARK: - Public API

    /// Suggests a category for the given account name using on-device AI.
    /// Returns nil if the device doesn't support Foundation Models or inference fails.
    func suggest(for accountName: String) async -> String? {
        let trimmed = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        guard #available(macOS 26, *) else { return nil }

        return await _suggest(for: trimmed)
    }

    // MARK: - Private (macOS 26+)

    @available(macOS 26, *)
    private func _suggest(for accountName: String) async -> String? {
        do {
            let session = LanguageModelSession(
                instructions: Self.promptV1
            )

            let response = try await session.respond(to: accountName)
            let result = response.content
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: ".", with: "")

            // Validate it's a known category
            let validCategories: Set<String> = [
                "Streaming", "Productivity", "Gaming", "Music", "News",
                "Storage", "Utilities", "Health", "Finance", "Shopping",
                "Education", "Social", "Communication", "Food", "Fitness",
                "Entertainment", "Developer", "Other"
            ]

            if validCategories.contains(result) {
                return result
            }

            // Try case-insensitive match
            if let match = validCategories.first(where: { $0.lowercased() == result.lowercased() }) {
                return match
            }

            return "Other"
        } catch {
            #if DEBUG
            print("[CategorySuggestion] Inference failed: \(error.localizedDescription)")
            #endif
            return nil
        }
    }
}
