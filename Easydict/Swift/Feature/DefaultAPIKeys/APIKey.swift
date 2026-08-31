//
//  APIKey.swift
//  Easydict
//
//  Created by tisfeng on 2024/2/15.
//  Copyright © 2024 izual. All rights reserved.
//

import Foundation

// MARK: - SecretKeyManager

@objcMembers
class SecretKeyManager: NSObject {
    static var keyValues: [String: String] {
        guard let path = Bundle.main.path(forResource: "EncryptedSecretKeys", ofType: "plist") else {
            return [:]
        }

        guard let dict = NSDictionary(contentsOfFile: path) else {
            return [:]
        }

        var decryptedKeyValues = [String: String]()
        for (key, value) in dict {
            if let key = key as? String, let value = value as? String {
                decryptedKeyValues[key] = value.decryptAES()
            }
        }

        return decryptedKeyValues
    }
}
