//
//  NSPasteboard+Extension.swift
//  Easydict
//
//  Created by tisfeng on 2025/7/13.
//  Copyright © 2025 izual. All rights reserved.
//

import Foundation

extension NSPasteboard {
    /// A convenience property to get and set string content on the pasteboard.
    @objc
    var string: String {
        get { string(forType: .string) ?? "" }
        set {
            clearContents()
            setString(newValue, forType: .string)
        }
    }
}
