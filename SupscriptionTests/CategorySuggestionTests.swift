//
//  CategorySuggestionTests.swift
//  SupscriptionTests
//
//  Created by Richie Flores on 4/2/26.
//

import XCTest
@testable import Supscription

final class CategorySuggestionTests: XCTestCase {

    // MARK: - Normalization Tests

    func testNormalize_exactMatch_returnsExisting() {
        let result = CategorySuggestionService.normalize(
            "Streaming",
            against: ["Streaming", "Gaming", "Productivity"]
        )
        XCTAssertEqual(result, "Streaming")
    }

    func testNormalize_caseInsensitiveMatch_returnsExistingSpelling() {
        let result = CategorySuggestionService.normalize(
            "Streaming",
            against: ["streaming", "gaming", "productivity"]
        )
        XCTAssertEqual(result, "streaming")
    }

    func testNormalize_noMatch_returnsOriginalSuggestion() {
        let result = CategorySuggestionService.normalize(
            "Developer",
            against: ["Streaming", "Gaming"]
        )
        XCTAssertEqual(result, "Developer")
    }

    func testNormalize_emptyExistingCategories_returnsOriginal() {
        let result = CategorySuggestionService.normalize(
            "Music",
            against: []
        )
        XCTAssertEqual(result, "Music")
    }

    func testNormalize_trimsWhitespace_inExistingCategories() {
        let result = CategorySuggestionService.normalize(
            "Gaming",
            against: ["  Gaming  ", "Streaming"]
        )
        XCTAssertEqual(result, "Gaming")
    }

    func testNormalize_mixedCaseInput_matchesExisting() {
        let result = CategorySuggestionService.normalize(
            "STREAMING",
            against: ["Streaming", "Gaming"]
        )
        XCTAssertEqual(result, "Streaming")
    }

    // MARK: - Input Validation Tests

    func testSuggest_emptyString_returnsNil() async {
        let result = await CategorySuggestionService.shared.suggest(for: "")
        XCTAssertNil(result)
    }

    func testSuggest_whitespaceOnly_returnsNil() async {
        let result = await CategorySuggestionService.shared.suggest(for: "   ")
        XCTAssertNil(result)
    }

    func testSuggest_withExistingCategories_emptyInput_returnsNil() async {
        let result = await CategorySuggestionService.shared.suggest(
            for: "",
            existingCategories: ["Streaming"]
        )
        XCTAssertNil(result)
    }

    // MARK: - Prompt Version Tests

    func testPromptV1_isNotEmpty() {
        XCTAssertFalse(CategorySuggestionService.promptV1.isEmpty)
    }

    func testPromptV1_containsOtherFallback() {
        XCTAssertTrue(CategorySuggestionService.promptV1.contains("Other"))
    }
}
