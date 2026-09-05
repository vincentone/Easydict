//
//  NSButton+Extension.swift
//  Easydict
//
//  Created by tisfeng on 2025/11/25.
//  Copyright © 2025 izual. All rights reserved.
//

import AppKit

// MARK: - NSButton Extension

extension NSButton {
    /// A Boolean value that indicates whether the button is in the "on" state.
    ///
    /// Setting this property to `true` sets the button's state to `.on`,
    /// and setting it to `false` sets the state to `.off`.
    ///
    /// - Example:
    /// ```swift
    /// let button = NSButton()
    /// button.isOn = true
    /// if button.isOn {
    ///     print("Button is on")
    /// }
    /// ```
    var isOn: Bool {
        get { state == .on }
        set { state = newValue ? .on : .off }
    }
}
