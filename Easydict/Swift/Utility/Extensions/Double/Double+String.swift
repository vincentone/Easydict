//
//  Double+String.swift
//  Easydict
//
//  Created by tisfeng on 2025/4/18.
//  Copyright © 2025 izual. All rights reserved.
//

import Foundation

// MARK: - Double Extensions

/// Convert double to string with one decimal place.
/// - Example:
///   - 1 -> "1.0"
///   - 1.234 -> "1.2"
extension Double {
    var string3f: String {
        String(format: "%.3f", self)
    }
}

/// Extension to get the elapsed time string from a CFAbsoluteTime value.
extension CFAbsoluteTime {
    /// Returns a string representing the elapsed time since this CFAbsoluteTime value.
    var elapsedTimeString: String {
        let elapsedTime = CFAbsoluteTimeGetCurrent() - self
        return elapsedTime.string3f
    }
}
