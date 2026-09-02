//
//  StatusBarController.swift
//  Easydict
//
//  Created by tisfeng on 2026/9/1.
//  Copyright © 2026 izual. All rights reserved.
//

import AppKit
import Combine
import Defaults
import SettingsAccess
import SwiftUI

// MARK: - SettingsAccessHostView

/// Hidden SwiftUI host embedded in the status item button.
///
/// It keeps the SettingsAccess injection alive so that programmatic settings
/// opening works, e.g. when the query window titlebar gear posts
/// `.openSettings` or the status bar menu item is clicked.
private struct SettingsAccessHostView: View {
    // MARK: Internal

    var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .openSettingsAccess()
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name.openSettings,
                    object: nil
                )
            ) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    // calling `openSettingsLegacy` immediately doesn't work so wait a quick moment
                    try? openSettingsLegacy()
                }
            }
    }

    // MARK: Private

    @Environment(\.openSettingsLegacy) private var openSettingsLegacy
}

// MARK: - StatusBarController

/// Manages the menu bar status item.
///
/// Left click opens the input translation window; right (or control) click
/// shows a compact menu with input translate, pasteboard translate and settings.
@objcMembers
final class StatusBarController: NSObject {
    // MARK: Lifecycle

    override private init() {
        super.init()
    }

    // MARK: Internal

    static let shared = StatusBarController()

    /// ObjC-friendly accessor for `shared`.
    @objc(sharedInstance)
    static func sharedInstance() -> StatusBarController {
        shared
    }

    /// Creates the status item and wires up icon, visibility and click actions.
    func setup() {
        configureButton()
        installSettingsAccessHost()
        buildMenu()
        observeConfigurations()
        updateVisibility()
    }

    // MARK: Private

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let statusMenu = NSMenu()
    private var cancellables: Set<AnyCancellable> = []

    private func configureButton() {
        guard let button = statusItem.button else { return }
        updateIcon()

        button.toolTip = "Easydict 🍃"
        button.target = self
        button.action = #selector(statusItemClicked)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp, .otherMouseUp])
    }

    /// Keeps the SettingsAccess injection view alive inside the status button.
    private func installSettingsAccessHost() {
        guard let button = statusItem.button else { return }
        let hostView = NSHostingView(rootView: SettingsAccessHostView())
        hostView.frame = NSRect(x: 0, y: 0, width: 1, height: 1)
        button.addSubview(hostView)
    }

    private func updateIcon() {
        guard let button = statusItem.button,
              let image = NSImage(named: Defaults[.selectedMenuBarIcon].rawValue)
        else {
            return
        }

        #if DEBUG
        image.isTemplate = false
        #else
        image.isTemplate = true
        #endif
        image.size = NSSize(width: 18, height: 18)
        button.image = image
    }

    private func updateVisibility() {
        statusItem.isVisible = !Defaults[.hideMenuBarIcon]
    }

    private func buildMenu() {
        statusMenu.autoenablesItems = false

        let inputItem = NSMenuItem(
            title: NSLocalizedString("menu_input_translate", comment: ""),
            action: #selector(openInputTranslate),
            keyEquivalent: "a"
        )
        inputItem.keyEquivalentModifierMask = [.option]
        inputItem.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)
        inputItem.target = self

        let pasteboardItem = NSMenuItem(
            title: NSLocalizedString("menu_pasteboard_translate", comment: ""),
            action: #selector(openPasteboardTranslate),
            keyEquivalent: "f"
        )
        pasteboardItem.keyEquivalentModifierMask = [.option]
        pasteboardItem.image = NSImage(
            systemSymbolName: "doc.on.clipboard",
            accessibilityDescription: nil
        )
        pasteboardItem.target = self

        let settingsItem = NSMenuItem(
            title: NSLocalizedString("Settings...", comment: ""),
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.keyEquivalentModifierMask = [.command]
        settingsItem.target = self

        statusMenu.addItem(inputItem)
        statusMenu.addItem(pasteboardItem)
        statusMenu.addItem(.separator())
        statusMenu.addItem(settingsItem)
    }

    private func observeConfigurations() {
        Defaults.publisher(.hideMenuBarIcon, options: [.initial])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateVisibility()
            }
            .store(in: &cancellables)

        Defaults.publisher(.selectedMenuBarIcon, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateIcon()
            }
            .store(in: &cancellables)
    }

    /// Left click opens the input translation window directly.
    @objc
    private func statusItemClicked() {
        let isMenuTrigger = NSApp.currentEvent.map { event in
            event.type == .rightMouseUp
                || event.type == .otherMouseUp
                || (event.type == .leftMouseUp && event.modifierFlags.contains(.control))
        } ?? false

        if isMenuTrigger {
            showMenu()
        } else {
            openInputTranslate()
        }
    }

    /// Assign the menu temporarily so that only this click pops it up.
    private func showMenu() {
        statusItem.menu = statusMenu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc
    private func openInputTranslate() {
        EZWindowManager.shared().inputTranslate()
    }

    @objc
    private func openPasteboardTranslate() {
        EZWindowManager.shared().pasteboardTranslate(.fixed)
    }

    /// Reuse the shared settings-opening pipeline; the hidden host view in the
    /// status button observes this notification.
    @objc
    private func openSettings() {
        NotificationCenter.default.post(name: Notification.Name.openSettings, object: nil)
    }
}
