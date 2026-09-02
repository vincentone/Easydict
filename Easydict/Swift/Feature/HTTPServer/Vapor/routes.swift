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

    /// OCR image data up to 10MB. https://docs.vapor.codes/basics/routing/
    app.on(.POST, "ocr", body: .collect(maxSize: "10mb")) { req async throws -> OCRResponse in
        let request = try req.content.decode(OCRRequest.self)

        let queryModel = QueryModel()
        queryModel.ocrImage = NSImage(data: request.imageData)

        var from = Language.auto
        if let sourceLanguage = request.sourceLanguage {
            from = Language.language(fromCode: sourceLanguage)
        }
        queryModel.userSourceLanguage = from

        let detectManager = DetectManager(model: queryModel)
        let result = try await detectManager.ocr()

        return OCRResponse(
            ocrText: result.mergedText,
            sourceLanguage: result.from.code
        )
    }

    /// Detect language
    app.post("detect") { req async throws -> DetectResponse in
        let request = try req.content.decode(DetectRequest.self)
        let queryModel = try await DetectManager().detectText(request.text)

        return DetectResponse(sourceLanguage: queryModel.detectedLanguage.code)
    }
}
