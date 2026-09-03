//
//  vapor.swift
//  Easydict
//
//  Created by tisfeng on 2024/7/15.
//  Copyright © 2024 izual. All rights reserved.
//

import MJExtension
import Vapor

func routes(_ app: Application) throws {
    app.get { _ async in
        "Hello, Welcome to Easydict server!"
    }

    /// Translate text
    app.post("translate") { req async throws -> TranslationResponse in
        let request = try req.content.decode(TranslationRequest.self)

        guard let service = QueryServiceFactory.shared.service(withTypeId: request.serviceType) else {
            throw QueryError(
                type: .unsupportedServiceType, message: "\(request.serviceType)"
            )
        }

        let result = try await service.translate(request: request)

        var response = TranslationResponse(
            translatedText: result.translatedText ?? "",
            sourceLanguage: result.from.code
        )

        // Decode word result to DictionaryEntry
        if let jsonData = result.wordResult?.mj_JSONData() {
            do {
                let decoder = JSONDecoder()
                let entry = try decoder.decode(DictionaryEntry.self, from: jsonData)
                response.dictionaryEntry = entry
            } catch {
                print("Decode DictionaryEntry failed: \(error)")
            }
        }

        return response
    }

    /// Detect language
    app.post("detect") { req async throws -> DetectResponse in
        let request = try req.content.decode(DetectRequest.self)
        let queryModel = try await DetectManager().detectText(request.text)

        return DetectResponse(sourceLanguage: queryModel.detectedLanguage.code)
    }
}
