//
//  CategorySuggestionService.swift
//  Supscription
//
//  Created by Richie Flores on 3/29/26.
//

import Foundation
import FoundationModels

// MARK: - Service

final class CategorySuggestionService {
    static let shared = CategorySuggestionService()
    private init() {}

    // MARK: - Prompt (versioned)

    static let promptV1 = """
    You are a subscription categorizer. Given the name of a subscription service or company, \
    respond with a single word that best describes the category. Examples: Streaming, \
    Productivity, Gaming, Music, News, Storage, Utilities, Health, Finance, Developer, \
    Entertainment, Education, Fitness, Shopping, Social, Communication, Food.

    Rules:
    - Respond with exactly one word, nothing else.
    - The word should be capitalized.
    - You are not limited to the examples above — use whatever single word best fits.
    - If the name is gibberish, random characters, or unrecognizable, respond with: Other
    - Do not explain your reasoning. Do not add punctuation.
    """

    // MARK: - Timeout

    private static let inferenceTimeoutSeconds: UInt64 = 10

    // MARK: - Public API

    /// Suggests a category for the given account name using on-device AI.
    /// Returns nil if the device doesn't support Foundation Models or inference fails.
    func suggest(for accountName: String) async -> String? {
        let trimmed = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        guard #available(macOS 26, *) else { return nil }

        return await _suggest(for: trimmed)
    }

    /// Suggests a category and normalizes against existing categories in the data store.
    /// If the AI returns "Streaming" but the user already has "streaming", uses "streaming".
    func suggest(for accountName: String, existingCategories: [String]) async -> String? {
        guard let suggested = await suggest(for: accountName) else { return nil }
        return Self.normalize(suggested, against: existingCategories)
    }

    // MARK: - Normalization

    /// Matches a suggested category against existing user categories (case-insensitive).
    /// Returns the existing spelling if found, otherwise the original suggestion.
    static func normalize(_ suggestion: String, against existing: [String]) -> String {
        let lowered = suggestion.lowercased()
        if let match = existing.first(where: {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == lowered
        }) {
            return match.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return suggestion
    }

    // MARK: - Private (macOS 26+)

    @available(macOS 26, *)
    private func _suggest(for accountName: String) async -> String? {
        // Check model availability
        guard SystemLanguageModel.default.availability == .available else {
            #if DEBUG
            print("[CategorySuggestion] Model not available on this device")
            #endif
            return nil
        }

        // Run inference with timeout
        do {
            return try await withThrowingTaskGroup(of: String?.self) { group in
                group.addTask {
                    let session = LanguageModelSession(
                        instructions: Self.promptV1
                    )
                    let response = try await session.respond(to: accountName)
                    let result = response.content
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .replacingOccurrences(of: ".", with: "")

                    // Ensure it's a single word, capitalized
                    guard !result.isEmpty else { return "Other" }

                    // Take only the first word if model returns multiple
                    let firstWord = result.components(separatedBy: .whitespaces).first ?? result
                    return firstWord.prefix(1).uppercased() + firstWord.dropFirst().lowercased()
                }

                group.addTask {
                    try await Task.sleep(nanoseconds: Self.inferenceTimeoutSeconds * 1_000_000_000)
                    throw CancellationError()
                }

                // Return whichever finishes first
                if let result = try await group.next() {
                    group.cancelAll()
                    return result
                }

                group.cancelAll()
                return nil
            }
        } catch {
            #if DEBUG
            print("[CategorySuggestion] Inference failed: \(error.localizedDescription)")
            #endif
            return nil
        }
    }
}
