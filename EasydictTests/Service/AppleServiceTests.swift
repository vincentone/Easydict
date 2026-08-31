//
//  AppleServiceTests.swift
//  EasydictSwiftTests
//
//  Created by tisfeng on 2025/7/3.
//  Copyright © 2025 izual. All rights reserved.
//

import Testing

@testable import Easydict

/// Tests for the Apple system-capability service (language detection and OCR)
@Suite("Apple Services", .tags(.apple, .integration))
struct AppleServiceTests {
    @Test("Apple Language Detection", .tags(.apple, .unit))
    func testLanguageDetection() {
        let apple = AppleService()

        #expect(apple.detectTextSync("Hello, world!") == .english)
        #expect(apple.detectTextSync("这是简体中文测试") == .simplifiedChinese)
    }
}
