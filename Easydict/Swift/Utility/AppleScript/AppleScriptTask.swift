//
//  AppleScriptTask.swift
//  Easydict
//
//  Created by tisfeng on 2024/9/8.
//

import Foundation

// MARK: - AppleScriptTask

/// Provides the app-facing AppleScript facade for system integrations. Business code depends
/// on this type instead of selecting an execution backend directly, so the preferred
/// `NSAppleScript` path stays centralized while still avoiding UI-thread blocking.
@objcMembers
class AppleScriptTask: NSObject {
    /// Run AppleScript with timeout control
    /// - Parameters:
    ///   - appleScript: The AppleScript to execute
    ///   - timeout: Maximum execution time in seconds, defaults to 10
    /// - Returns: Optional string result from the AppleScript execution
    /// - Throws: QueryError if execution fails or times out
    /// - Note: Execution is dispatched to a background queue so AppleScript work does not occupy the
    ///   UI thread. Timeout is best-effort only and cannot forcibly interrupt a running script.
    @discardableResult
    static func runAppleScript(_ appleScript: String, timeout: TimeInterval = 10) async throws
        -> String? {
        try await AppleScriptExecutor().run(appleScript, timeout: timeout)
    }
}
