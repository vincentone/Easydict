//
//  AppleServiceTests.swift
//  EasydictSwiftTests
//
//  Created by tisfeng on 2025/7/3.
//  Copyright © 2025 izual. All rights reserved.
//

import Foundation
import Testing

@testable import Easydict

// MARK: - AppleServiceTests

/// Tests for the Apple system-capability service (language detection and OCR)
@Suite("Apple Services", .tags(.apple, .integration))
struct AppleServiceTests {
    @Test("Apple Language Detection", .tags(.apple, .unit))
    func testLanguageDetection() {
        let apple = AppleService()

        #expect(apple.detectTextSync("Hello, world!") == .english)
        #expect(apple.detectTextSync("这是简体中文测试") == .simplifiedChinese)
    }
}

// MARK: - YoudaoBilingualSentenceTests

/// Tests for Youdao bilingual sentences parsing and data mapping
@Suite("Youdao Bilingual Sentences", .tags(.unit))
struct YoudaoBilingualSentenceTests {
    @Test("Decode and map bilingual example sentences")
    func testBilingualSentencesMapping() throws {
        let json = """
        {
            "blng_sents_part": {
                "sentence-count": 2,
                "sentence-pair": [
                    {
                        "sentence": "I'm good at French.",
                        "sentence-eng": "I'm <b>good</b> at French.",
                        "sentence-translation": "我的法语很好。",
                        "source": "《牛津词典》",
                        "sentence-speech": "I%27m+good+at+French.&le=eng"
                    },
                    {
                        "sentence": "I'll look up to you.",
                        "sentence-eng": "I'll <b>look</b> <b>up</b> to you.",
                        "sentence-translation": "我会尊敬你的。",
                        "source": "《柯林斯英汉双解大词典》",
                        "sentence-speech": "I%27ll+look+up+to+you.&le=eng"
                    }
                ]
            }
        }
        """

        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(YoudaoDictResponseV4.self, from: data)

        let result = QueryResult()
        result.update(dictV4: response)

        let sentences = try #require(result.wordResult?.sentences)
        #expect(sentences.count == 2)

        #expect(sentences[0].sentence == "I'm good at French.")
        #expect(sentences[0].translation == "我的法语很好。")
        #expect(sentences[0].source == "《牛津词典》")
        #expect(sentences[0].speechURL == "https://dict.youdao.com/dictvoice?audio=I%27m+good+at+French.&le=eng")

        #expect(sentences[1].sentence == "I'll look up to you.")
        #expect(sentences[1].translation == "我会尊敬你的。")
        #expect(sentences[1].source == "《柯林斯英汉双解大词典》")
        #expect(sentences[1].speechURL == "https://dict.youdao.com/dictvoice?audio=I%27ll+look+up+to+you.&le=eng")
    }

    @Test("Decode Chinese to English bilingual sentences with translation speech")
    func testChineseBilingualSentencesMapping() throws {
        let json = """
        {
            "blng_sents_part": {
                "sentence-count": 1,
                "sentence-pair": [
                    {
                        "sentence": "英、美、法军队的主力向西面散开。",
                        "sentence-translation-speech": "The+main+body+of+British%2C+American%2C+and+French+troops+had+fanned+out+to+the+west.&le=eng",
                        "sentence-eng": "英、<b>美</b>、法军队的主力向西面散开。",
                        "sentence-translation": "The main body of British, American, and French troops had fanned out to the west.",
                        "source": "《柯林斯英汉双解大词典》"
                    }
                ]
            }
        }
        """

        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(YoudaoDictResponseV4.self, from: data)

        let result = QueryResult()
        result.update(dictV4: response)

        let sentences = try #require(result.wordResult?.sentences)
        #expect(sentences.count == 1)
        #expect(sentences[0].sentence == "英、美、法军队的主力向西面散开。")
        #expect(sentences[0]
            .translation == "The main body of British, American, and French troops had fanned out to the west.")
        #expect(sentences[0].source == "《柯林斯英汉双解大词典》")
        #expect(sentences[0]
            .speechURL ==
            "https://dict.youdao.com/dictvoice?audio=The+main+body+of+British%2C+American%2C+and+French+troops+had+fanned+out+to+the+west.&le=eng")
    }
}
