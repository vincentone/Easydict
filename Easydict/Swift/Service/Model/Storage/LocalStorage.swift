//
//  LocalStorage.swift
//  Easydict
//
//  Created by tisfeng on 2022/11/22.
//

import Foundation

// MARK: - LocalStorage

/// Local persistence layer for app usage counters.
@objc(EZLocalStorage)
@objcMembers
final class LocalStorage: NSObject {
    // MARK: Lifecycle

    private override init() {
        super.init()
    }

    // MARK: Internal

    // MARK: Public API

    /// Total query character count.

    var queryCharacterCount: Int {
        get { userDefaults.integer(forKey: Constants.queryCharacterCountKey) }
        set { userDefaults.set(newValue, forKey: Constants.queryCharacterCountKey) }
    }

    /// Total query count.

    var queryCount: Int {
        get { userDefaults.integer(forKey: Constants.queryCountKey) }
        set { userDefaults.set(newValue, forKey: Constants.queryCountKey) }
    }

    /// Resets all stored data (used by the reset URL scheme).
    static func destroySharedInstance() {
        sharedInstance = nil
    }

    /// Increases the query counter, tracking query characters as well.
    func increaseQueryCount(_ text: String) {
        queryCount += 1
        queryCharacterCount += (text as NSString).length
    }

    // MARK: Private

    private enum Constants {
        static let queryCountKey = "kQueryCountKey"
        static let queryCharacterCountKey = "kQueryCharacterCountKey"
    }

    private static var sharedInstance: LocalStorage?

    private let userDefaults = UserDefaults.standard
}
