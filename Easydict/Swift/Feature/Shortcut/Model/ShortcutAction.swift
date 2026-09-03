//
//  ShortcutAction.swift
//  Easydict
//
//  Created by tisfeng on 2025/8/25.
//  Copyright © 2025 izual. All rights reserved.
//

import Defaults
import Foundation
import Magnet
import SFSafeSymbols

// MARK: - ShortcutAction

/// Enum representing different application actions that can be triggered by shortcuts
public enum ShortcutAction: String, Identifiable, CaseIterable {
    // Global shortcuts
    case inputTranslate

    // MARK: Public

    public var id: String { rawValue }
}

extension ShortcutAction {
    /// All global shortcut actions (system-wide hotkeys)
    static let globalActions: [ShortcutAction] = [
        .inputTranslate,
    ]

    /// All app-specific shortcut actions (only active when app is focused)
    static var appActions: [ShortcutAction] {
        allCases.filter { !globalActions.contains($0) }
    }

    /// Whether this action is a global shortcut (system-wide hotkey)
    var isGlobal: Bool {
        Self.globalActions.contains(self)
    }

    /// Get configuration for the shortcut type
    var configuration: ActionConfiguration {
        Self.configurations[self]
            ?? .init(
                titleKey: "unknown",
                icon: .questionmark,
                defaultsKey: nil,
                action: {}
            )
    }

    func localizedStringKey() -> String {
        configuration.titleKey
    }

    var icon: SFSymbol {
        configuration.icon
    }

    @MainActor
    func executeAction() {
        Task {
            await configuration.action()
        }
    }

    /// Get the Defaults.Key for this shortcut action
    var defaultsKey: Defaults.Key<KeyCombo?>? {
        configuration.defaultsKey
    }
}

// MARK: - ShortcutAction Configurations

extension ShortcutAction {
    /// Static configurations for all shortcut types
    fileprivate static let configurations: [ShortcutAction: ActionConfiguration] = {
        let windowManager = EZWindowManager.shared()

        return [
            // Global shortcuts
            .inputTranslate: .init(
                titleKey: "menu_input_translate",
                icon: .keyboard,
                defaultsKey: .inputShortcut,
                action: { windowManager.inputTranslate() }
            ),
        ]
    }()
}
