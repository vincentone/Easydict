//
//  MyConfiguration.swift
//  Easydict
//
//  Created by ljk on 2024/1/2.
//  Copyright © 2024 izual. All rights reserved.
//

import Combine
import Defaults
import Foundation

// MARK: - EnglishPronunciation

@objc
enum EnglishPronunciation: Int {
    case uk = 1
    case us
}

// MARK: - MyConfiguration

/// Singleton class to manage application configuration settings.
/// This class uses the `Defaults` library to persist settings and provides
/// reactive updates using Combine.
@objcMembers
class MyConfiguration: NSObject {
    // MARK: Lifecycle

    override private init() {
        super.init()
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            observeKeys()
        }
    }

    // MARK: Internal

    private(set) static var shared = MyConfiguration()

    @DefaultsWrapper(.firstLanguage) var firstLanguage: Language
    @DefaultsWrapper(.secondLanguage) var secondLanguage: Language
    @DefaultsWrapper(.queryFromLanguage) var fromLanguage: Language
    @DefaultsWrapper(.queryToLanguage) var toLanguage: Language

    @DefaultsWrapper(.fixedWindowPosition) var fixedWindowPosition: EZShowWindowPosition
    @DefaultsWrapper(.pinWindowWhenDisplayed) var pinWindowWhenDisplayed

    @DefaultsWrapper(.clearQueryWhenInputTranslate) var clearInput: Bool
    @DefaultsWrapper(.selectQueryTextWhenWindowActivate) var selectQueryTextWhenWindowActivate: Bool
    @DefaultsWrapper(.autoQueryPastedText) var autoQueryPastedText: Bool
    @DefaultsWrapper(.autoQueryWhenTextChanged) var autoQueryWhenTextChanged: Bool
    @DefaultsWrapper(.autoPlayAudio) var autoPlayAudio: Bool
    @DefaultsWrapper(.pronunciation) var pronunciation: EnglishPronunciation
    @DefaultsWrapper(.preferYoudaoTTSForEnglishWord) var preferYoudaoTTSForEnglishWord: Bool

    @DefaultsWrapper(.autoCopyFirstTranslatedText) var autoCopyFirstTranslatedText: Bool

    @DefaultsWrapper(.appearanceType) var appearance: AppearanceType
    @DefaultsWrapper(.hideMenuBarIcon) var hideMenuBarIcon: Bool
    @DefaultsWrapper(.fontSizeOptionIndex) var fontSizeIndex: UInt

    @DefaultsWrapper(.formerFixedScreenVisibleFrame) var formerFixedScreenVisibleFrame: CGRect

    // Max window height percentage, e.g., 80 means 80% of the screen height
    @DefaultsWrapper(.maxWindowHeightPercentage) var maxWindowHeightPercentage: Int

    @ShortcutWrapper(.pinShortcut) var pinShortcutString: String

    let fontSizes: [CGFloat] = [1, 1.1, 1.2, 1.3, 1.4]
    var disabledAutoSelect: Bool = false
    var isRecordingSelectTextShortcutKey: Bool = false
    var cancellables: Set<AnyCancellable> = []

    var fontSizeRatio: CGFloat {
        let safeIndex = max(0, min(Int(fontSizeIndex), fontSizes.count - 1))
        return fontSizes[safeIndex]
    }

    static func destroySharedInstance() {
        shared = MyConfiguration()
    }

    // MARK: Private

    private func observeKeys() {
        Defaults.publisher(.appearanceType, options: [])
            .removeDuplicates()
            .sink { [weak self] change in
                let newValue = change.newValue
                self?.didSetAppearance(newValue)
            }
            .store(in: &cancellables)

        Defaults.publisher(.fontSizeOptionIndex, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetFontSizeIndex()
            }
            .store(in: &cancellables)
    }

    private func didSetFontSizeIndex() {
        NotificationCenter.default.post(name: .didChangeFontSize, object: nil)
    }

    private func didSetAppearance(_ appearance: AppearanceType) {
        DarkModeManager.shared.updateDarkMode(appearance)
    }
}
