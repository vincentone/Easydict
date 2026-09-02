//
//  SystemUtilitiesTests.swift
//  EasydictSwiftTests
//
//  Created by tisfeng on 2025/7/3.
//  Copyright © 2025 izual. All rights reserved.
//

import Testing

@testable import Easydict

/// Tests for system utilities and macOS integrations
@Suite("System Utilities", .tags(.system, .integration))
struct SystemUtilitiesTests {
    @Test("Alert Volume Control", .tags(.system))
    func testAlertVolume() async throws {
        let originalVolume = try await AppleScriptTask.alertVolume()
        print("Original volume: \(originalVolume)")

        let testVolume = 50
        try await AppleScriptTask.setAlertVolume(testVolume)

        let newVolume = try await AppleScriptTask.alertVolume()
        #expect(newVolume == testVolume)

        try await AppleScriptTask.setAlertVolume(originalVolume)
        #expect(true, "Alert volume test completed")
    }
}
