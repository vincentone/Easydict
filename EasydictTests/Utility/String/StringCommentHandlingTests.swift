//
//  StringCommentHandlingTests.swift
//  EasydictTests
//
//  Created by Claude on 2025/1/29.
//  Copyright © 2025 izual. All rights reserved.
//

import Testing

@testable import Easydict

/// Tests for String comment handling extensions
@Suite("String Comment Handling", .tags(.utilities, .unit))
struct StringCommentHandlingTests {
    // MARK: - Comment Symbol Detection

    @Test("Comment symbol detection")
    func commentSymbolDetection() {
        let testCases = [
            ("# This is a comment\n// Another comment", true),
            ("# Comment\nNot a comment", false),
            ("/* Block comment */\n* Another", false),
            ("Normal text\n// Comment", false),
            ("// Only comments\n# More comments\n* And more", true),
            ("", false),
            ("   # Indented comment", true),
        ]

        for (input, expected) in testCases {
            #expect(input.allLineStartsWithCommentSymbol() == expected, "Failed for input: \(input)")
        }
    }

    // MARK: - Comment Block Removal

    @Test("Comment block removal")
    func commentBlockRemoval() {
        let input = """
        // This is a comment
        // with multiple lines
        """

        let result = input.removingCommentBlockSymbols()
        #expect(result.contains("This is a comment"))
        #expect(result.contains("with multiple lines"))
        #expect(!result.contains("//"))
    }
}
