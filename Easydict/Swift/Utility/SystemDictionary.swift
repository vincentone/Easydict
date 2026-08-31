//
//  SystemDictionary.swift
//  Easydict
//
//  Created by tisfeng on 2026/8/31.
//  Copyright © 2026 izual. All rights reserved.
//

import Foundation

// MARK: - SystemDictionary

/// Lightweight helper around the system DictionaryKit lookup.
/// It replaces the former AppleDictionary query service and only exposes the
/// word-existence check needed by text segmentation.
@objcMembers
final class SystemDictionary: NSObject {
    /// Returns `true` when the system dictionary has a matching entry for the
    /// given word in the specified language.
    static func containsWord(_ word: String, language: Language) -> Bool {
        let languageDict = TTTDictionary.languageToDictionaryNameMap
        guard let dictName = languageDict.object(forKey: language as NSString) as? String else {
            return false
        }

        let dictionary = TTTDictionary(named: dictName)
        let entries = dictionary.entries(forSearchTerm: word)

        let normalizedWord = word.foldedString()
        for entry in entries {
            let normalizedHeadword = entry.headword.foldedString()

            // Filter results like "-log", "log-" when querying "log".
            let remainedText = normalizedHeadword.replacingOccurrences(of: normalizedWord, with: "")
            if remainedText == "-" {
                continue
            }

            if normalizedWord.caseInsensitiveCompare(normalizedHeadword) == .orderedSame {
                return true
            }
        }
        return false
    }
}
