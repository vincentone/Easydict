//
//  DetectManager.swift
//  Easydict
//
//  Created by tisfeng on 2022/11/5.
//  Copyright © 2024 izual. All rights reserved.
//

import Foundation
import SystemConfiguration

// MARK: - DetectManager

/// Manager for on-device language detection.
@objc(EZDetectManager)
@objcMembers
public final class DetectManager: NSObject {
    // MARK: Lifecycle

    /// Initializes a new detect manager with the specified query model.
    /// - Parameter model: The query model containing text and image data.
    public init(model: QueryModel) {
        self.queryModel = model

        super.init()
    }

    /// Initializes a new detect manager with an empty query model.
    public override convenience init() {
        self.init(model: QueryModel())
        self.allowsDetachedDetection = true
    }

    // MARK: Public

    /// The query model containing text and image data to be processed.
    public var queryModel: QueryModel

    // MARK: - Static Factory

    /// Creates a new detect manager with the specified query model.
    /// - Parameter model: The query model containing text and image data.
    /// - Returns: A new detect manager instance.
    @objc(managerWithModel:)
    public static func manager(with model: QueryModel) -> DetectManager {
        DetectManager(model: model)
    }

    // MARK: - Public Methods

    /// Detects the language of the given text using Apple's on-device detection.
    /// - Parameters:
    ///   - queryText: The text to detect the language of.
    ///   - completion: Callback with the updated query model and optional error.
    public func detectText(_ queryText: String, completion: @escaping (QueryModel, Error?) -> ()) {
        guard !queryText.isEmpty else {
            let errorMessage = "detectText cannot be nil"
            logError(errorMessage)
            completion(queryModel, QueryError.error(type: .parameter, message: errorMessage))
            return
        }

        appleService.detectText(queryText) { [weak self] appleDetectedLanguage, error in
            guard let self else {
                completion(QueryModel(), error)
                return
            }
            guard canApplyDetectedLanguage(for: queryText) else {
                completion(queryModel, staleDetectionError())
                return
            }

            handleDetectedLanguage(
                appleDetectedLanguage,
                queryText: queryText,
                error: error,
                completion: completion
            )
        }
    }

    /// Checks if a system proxy is configured.
    /// - Returns: `true` if an HTTP proxy is enabled, `false` otherwise.
    @objc(checkIfHasProxy)
    public func checkIfHasProxy() -> Bool {
        guard let proxies = SCDynamicStoreCopyProxies(nil) as? [String: Any] else {
            return false
        }

        let httpProxy = proxies[kSCPropNetProxiesHTTPEnable as String] as? Bool
        let httpEnable = proxies[kSCPropNetProxiesHTTPEnable as String] as? Int

        return (httpProxy == true) || (httpEnable == 1)
    }

    // MARK: Private

    // MARK: - Private Properties

    private var allowsDetachedDetection = false

    private lazy var appleService: AppleService = .shared

    // MARK: - Private Methods

    private func canApplyDetectedLanguage(for queryText: String) -> Bool {
        allowsDetachedDetection || queryModel.queryText == queryText
    }

    private func staleDetectionError() -> QueryError {
        QueryError.error(type: .parameter, message: "Stale language detection result")
    }

    /// Handles the detected language by updating the query model and calling the completion handler.
    /// - Parameters:
    ///   - language: The detected language.
    ///   - error: Optional error from the detection.
    ///   - completion: Completion to invoke with the updated query model and error.
    private func handleDetectedLanguage(
        _ language: Language,
        queryText: String,
        error: Error?,
        completion: @escaping (QueryModel, Error?) -> ()
    ) {
        guard canApplyDetectedLanguage(for: queryText) else {
            completion(queryModel, staleDetectionError())
            return
        }
        queryModel.detectedLanguage = language

        // If detection succeeded, we don't need to detect again temporarily.
        queryModel.needDetectLanguage = (error != nil)

        completion(queryModel, error)
    }
}

// MARK: - DetectManager + Async

extension DetectManager {
    /// Asynchronously detects the language of the given text.
    /// - Parameter text: The text to detect language of.
    /// - Returns: The query model with detected language set.
    @nonobjc
    public func detectText(_ text: String) async throws -> QueryModel {
        try await withCheckedThrowingContinuation { continuation in
            detectText(text) { queryModel, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: queryModel)
                }
            }
        }
    }
}
