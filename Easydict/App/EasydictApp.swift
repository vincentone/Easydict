//
//  EasydictApp.swift
//  Easydict
//
//  Created by Kyle on 2023/12/28.
//  Copyright © 2023 izual. All rights reserved.
//

import Defaults
import SwiftUI

// MARK: - EasydictCmpatibilityEntry

@main
enum EasydictCmpatibilityEntry {
    static func main() {
        parseArmguments()

        // Capturing crash logs must be placed first.
        MMCrash.registerHandler()

        // Workaround for macOS 26 Tahoe WindowServer high GPU load: NSWindow subclasses
        // that directly override `_cornerMask` defeat AppKit's mask cache and force the
        // compositor to re-render every frame. Must run before any window is created.
        // See https://github.com/electron/electron/issues/48311
        if #available(macOS 26, *) {
            EZPatchWindowServerCornerMask()
        }

        // Workaround for macOS 26 Tahoe: AppKit's AutoFill heuristics launch
        // a per-app "AutoFill" helper process (SafariPlatformSupport.Helper)
        // on text input. Easydict needs no system AutoFill suggestions, so
        // disable the heuristics to keep that helper from spawning.
        if #available(macOS 26, *) {
            UserDefaults.standard.register(
                defaults: ["NSAutoFillHeuristicsEnabled": false]
            )
        }

        // app launch
        EasydictApp.main()
    }
}

// MARK: - EasydictApp

struct EasydictApp: App {
    // MARK: Internal

    var body: some Scene {
        Settings {
            SettingView()
                .environmentObject(languageState)
                .environment(\.locale, .init(identifier: I18nHelper.shared.localizeCode))
        }
        .commands {
            EasydictMainMenu() // main menu
        }
    }

    // MARK: Private

    @NSApplicationDelegateAdaptor private var delegate: AppDelegate

    @StateObject private var languageState = LanguageState()
}

// MARK: - MenuBarIconType

enum MenuBarIconType: String, CaseIterable, Defaults.Serializable, Identifiable {
    case square = "square_menu_bar_icon"
    case rounded = "rounded_menu_bar_icon"

    // MARK: Internal

    var id: Self { self }
}
