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
    @DefaultsWrapper(.automaticallyRemoveCodeCommentSymbols) var automaticallyRemoveCodeCommentSymbols: Bool
    @DefaultsWrapper(.automaticWordSegmentation) var automaticWordSegmentation: Bool
    @DefaultsWrapper(.replaceNewlineWithSpace) var replaceNewlineWithSpace: Bool

    @DefaultsWrapper(.autoQueryPastedText) var autoQueryPastedText: Bool
    @DefaultsWrapper(.autoQueryWhenTextChanged) var autoQueryWhenTextChanged: Bool
    @DefaultsWrapper(.autoPlayAudio) var autoPlayAudio: Bool
    @DefaultsWrapper(.pronunciation) var pronunciation: EnglishPronunciation
    @DefaultsWrapper(.preferYoudaoTTSForEnglishWord) var preferYoudaoTTSForEnglishWord: Bool

    @DefaultsWrapper(.autoCopyFirstTranslatedText) var autoCopyFirstTranslatedText: Bool

    @DefaultsWrapper(.appearanceType) var appearance: AppearanceType
    @DefaultsWrapper(.hideMenuBarIcon) var hideMenuBarIcon: Bool
    @DefaultsWrapper(.fontSizeOptionIndex) var fontSizeIndex: UInt

    // Advanced Tab
    @DefaultsWrapper(.disableTipsView) var disableTipsView: Bool
    @DefaultsWrapper(.enableBetaFeature) private(set) var beta: Bool

    @DefaultsWrapper(.formerFixedScreenVisibleFrame) var formerFixedScreenVisibleFrame: CGRect

    // Max window height percentage, e.g., 80 means 80% of the screen height
    @DefaultsWrapper(.maxWindowHeightPercentage) var maxWindowHeightPercentage: Int

    @DefaultsWrapper(.allowCrashLog) var allowCrashLog: Bool
    @DefaultsWrapper(.allowAnalytics) var allowAnalytics: Bool

    @ShortcutWrapper(.pinShortcut) var pinShortcutString: String

    let fontSizes: [CGFloat] = [1, 1.1, 1.2, 1.3, 1.4]
    var disabledAutoSelect: Bool = false
    var isRecordingSelectTextShortcutKey: Bool = false
    var cancellables: Set<AnyCancellable> = []

    var fontSizeRatio: CGFloat {
        let safeIndex = max(0, min(Int(fontSizeIndex), fontSizes.count - 1))
        return fontSizes[safeIndex]
    }

    var defaultTTSServiceType: ServiceType {
        get {
            ServiceType(rawValue: Defaults[.defaultTTSServiceType].rawValue)
        }
        set {
            Defaults[.defaultTTSServiceType] =
                TTSServiceType(rawValue: newValue.rawValue) ?? .youdao
        }
    }

    static func destroySharedInstance() {
        shared = MyConfiguration()
    }

    func enableBetaFeaturesIfNeeded() {
        guard beta else { return }
    }

    // MARK: Private

    // swiftlint:disable:next function_body_length
    private func observeKeys() {
        Defaults.publisher(.firstLanguage, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetFirstLanguage()
            }
            .store(in: &cancellables)

        Defaults.publisher(.secondLanguage, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetSecondLanguage()
            }
            .store(in: &cancellables)

        Defaults.publisher(.autoQueryPastedText, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetAutoQueryPastedText()
            }
            .store(in: &cancellables)

        Defaults.publisher(.autoPlayAudio, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetAutoPlayAudio()
            }
            .store(in: &cancellables)

        Defaults.publisher(.pronunciation, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetPronunciation()
            }
            .store(in: &cancellables)

        Defaults.publisher(.autoCopyFirstTranslatedText, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetAutoCopyFirstTranslatedText()
            }
            .store(in: &cancellables)

        Defaults.publisher(.defaultTTSServiceType, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetDefaultTTSServiceType()
            }
            .store(in: &cancellables)

        Defaults.publisher(.hideMenuBarIcon, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetHideMenuBarIcon()
            }
            .store(in: &cancellables)

        Defaults.publisher(.fixedWindowPosition, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetFixedWindowPosition()
            }
            .store(in: &cancellables)

        Defaults.publisher(.allowCrashLog, options: [.initial])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetAllowCrashLog()
            }
            .store(in: &cancellables)

        Defaults.publisher(.allowAnalytics, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetAllowAnalytics()
            }
            .store(in: &cancellables)

        Defaults.publisher(.clearQueryWhenInputTranslate, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetClearInput()
            }
            .store(in: &cancellables)

        Defaults.publisher(.fontSizeOptionIndex, options: [])
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.didSetFontSizeIndex()
            }
            .store(in: &cancellables)

        Defaults.publisher(.appearanceType, options: [])
            .removeDuplicates()
            .sink { [weak self] change in
                let newValue = change.newValue
                self?.didSetAppearance(newValue)
            }
            .store(in: &cancellables)

        Defaults.publisher(
            keys: [.pinShortcut],
            options: []
        )
        .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true)
        .sink { _ in
            EZWindowManager.shared().updateWindowsTitlebarButtonsToolTip()
        }
        .store(in: &cancellables)

        Defaults.publisher(.enableHTTPServer)
            .removeDuplicates()
            .sink { change in
                let isOn = change.newValue
                Task {
                    await VaporServer.shared.startServer(isOn: isOn)
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: setter

extension MyConfiguration {
    fileprivate func didSetFirstLanguage() {
        logSettings(["first_language": firstLanguage])
    }

    fileprivate func didSetSecondLanguage() {
        logSettings(["second_language": secondLanguage])
    }

    fileprivate func didSetAutoQueryPastedText() {
        logSettings(["auto_query_pasted_text": autoQueryPastedText])
    }

    fileprivate func didSetAutoPlayAudio() {
        logSettings(["auto_play_word_audio": autoPlayAudio])
    }

    fileprivate func didSetPronunciation() {
        logSettings(["english_pronunciation": pronunciation])
    }

    fileprivate func didSetAutoCopyFirstTranslatedText() {
        logSettings(["auto_copy_first_translated_text": autoCopyFirstTranslatedText])
    }

    fileprivate func didSetDefaultTTSServiceType() {
        let value = defaultTTSServiceType
        logSettings(["tts": value])
    }

    fileprivate func didSetHideMenuBarIcon() {
        logSettings(["hide_menu_bar_icon": hideMenuBarIcon])
    }

    fileprivate func didSetFixedWindowPosition() {
        logSettings(["show_fixed_window_position": fixedWindowPosition])
    }

    fileprivate func didSetAllowCrashLog() {
        AnalyticsService.setCrashEnabled(allowCrashLog)
        logSettings(["allow_crash_log": allowCrashLog])
    }

    fileprivate func didSetAllowAnalytics() {
        logSettings(["allow_analytics": allowAnalytics])
    }

    fileprivate func didSetClearInput() {
        logSettings(["clear_input": clearInput])
    }

    fileprivate func didSetFontSizeIndex() {
        NotificationCenter.default.post(name: .didChangeFontSize, object: nil)
    }

    fileprivate func didSetAppearance(_ appearance: AppearanceType) {
        DarkModeManager.shared.updateDarkMode(appearance)
    }
}

extension MyConfiguration {
    fileprivate func logSettings(_ parameters: [String: Any]) {
        AnalyticsService.logEvent(withName: "settings", parameters: parameters)
    }
}
