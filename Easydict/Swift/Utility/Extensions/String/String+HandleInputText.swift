//
//  String+HandleInputText.swift
//  Easydict
//
//  Created by tisfeng on 2023/10/12.
//  Copyright © 2023 izual. All rights reserved.
//

import AppKit
import Foundation

// MARK: - String Input Text Handling

extension String {
    // MARK: Public Methods

    /// Split code text by snake case and camel case, then filter empty parts
    func splitCodeText() -> String {
        var queryText = splitSnakeCaseText()
        queryText = queryText.splitCamelCaseText()

        // Filter empty text parts
        let texts = queryText.components(separatedBy: " ")
        let nonEmptyTexts = texts.filter { !$0.isEmpty }
        queryText = nonEmptyTexts.joined(separator: " ")

        return queryText
    }

    /// Remove comment block symbols (/* */) and join texts intelligently
    func removingCommentBlockSymbols() -> String {
        (self as NSString).removeCommentBlockSymbols() as String
    }

    /// Check if all lines start with comment symbols (#, //, *)
    func allLineStartsWithCommentSymbol() -> Bool {
        (self as NSString).allLineStartsWithCommentSymbol()
    }

    /// Segment English text to words
    func segmentWords() -> String {
        (self as NSString).segmentWords() as String
    }

    /// Handle input text, trimming whitespace and newlines.
    func handleInputText() -> NSString {
        (self as NSString).ns_trim as NSString
    }

    // MARK: Private Methods

    private static let commentSymbolPrefixPattern = #"^\s*(//+|#+|\*+)"#

    /// Remove comment block symbols inline (/* ... */)
    private func removeCommentBlockSymbolsInline() -> NSString {
        var mutableSelf = self as String

        let pattern = #"/\*+(.*?)\*+/"#
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: .dotMatchesLineSeparators
        )
        else {
            return self
        }

        let matches = regex.matches(
            in: mutableSelf,
            range: NSRange(mutableSelf.startIndex..., in: mutableSelf)
        )

        // Process matches in reverse order to preserve indices
        for match in matches.reversed() {
            guard let contentRange = Range(match.range(at: 1), in: mutableSelf),
                  let fullRange = Range(match.range, in: mutableSelf)
            else {
                continue
            }

            let content = String(mutableSelf[contentRange]).trimmingCharacters(in: .whitespaces)
            let modifiedText = removeCommentSymbolPrefixAndJoinTexts(content)
            mutableSelf.replaceSubrange(fullRange, with: modifiedText)
        }

        return mutableSelf as NSString
    }

    /// Remove comment symbols and join texts with intelligent spacing
    private func removeCommentSymbolPrefixAndJoinTexts(_ content: String) -> String {
        let lines = content.components(separatedBy: .newlines)

        // Calculate text widths for layout analysis
        let widths = textsWidths(lines)

        // Get maximum width for layout calculations
        guard let maxWidthValue = widths.max() else { return content }
        let maxWidthIndex = widths.firstIndex(of: maxWidthValue) ?? 0
        let lineAtMaxWidth = lines[maxWidthIndex]

        guard !lineAtMaxWidth.isEmpty else { return content }

        // Calculate average character width
        let singleAlphabetWidth = maxWidthValue / CGFloat(lineAtMaxWidth.count)

        // Determine if language uses spaces between words
        let detectedLanguage = AppleService.shared.detectTextSync(content)
        let isEnglishTypeLanguage = EZLanguageManager.shared().isLanguageWordsNeedSpace(
            detectedLanguage
        )
        let alphabetCount: CGFloat = isEnglishTypeLanguage ? 15 : 1.5

        var modifiedBlockText = ""

        for (index, line) in lines.enumerated() {
            // Remove comment prefixes
            let newText = line.replacingOccurrences(
                of: Self.commentSymbolPrefixPattern,
                with: "",
                options: .regularExpression,
                range: nil
            )

            if index > 0 {
                let threshold = alphabetCount * singleAlphabetWidth
                let isPrevLineLongText = maxWidthValue - widths[index - 1] <= threshold
                let isPrevLineEnd = lines[index - 1].hasEndPunctuationSuffix
                let newTrimmedText = newText.trimmingCharacters(in: .whitespaces)

                if !newTrimmedText.isEmpty, isPrevLineLongText, !isPrevLineEnd {
                    let wordConnector = isEnglishTypeLanguage ? " " : ""
                    modifiedBlockText += "\(wordConnector)\(newTrimmedText)"
                } else {
                    modifiedBlockText += "\n\(newText)"
                }
            } else {
                modifiedBlockText = newText
            }
        }

        return modifiedBlockText
    }

    /// Check if string starts with comment symbol
    private func startsWithCommentSymbol(_ line: String) -> Bool {
        line.range(of: Self.commentSymbolPrefixPattern, options: .regularExpression) != nil
    }

    /// Calculate widths for an array of texts using system font
    private func textsWidths(_ texts: [String]) -> [CGFloat] {
        let font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        return texts.map { $0.width(with: font) }
    }
}
