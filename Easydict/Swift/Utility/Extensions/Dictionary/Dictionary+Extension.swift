//
//  Dictionary+Extension.swift
//  Easydict
//
//  Created by tisfeng on 2024/8/19.
//

import Foundation

extension Dictionary {
    /// Convert dictionary to a pretty-printed JSON string
    var prettyPrinted: NSString {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
        guard let data = jsonData, let jsonString = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return jsonString as NSString
    }
}
