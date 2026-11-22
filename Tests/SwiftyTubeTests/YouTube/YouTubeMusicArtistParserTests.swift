//
//  YouTubeMusicArtistParserTests.swift
//  SwiftyTubeTests
//
//  Created by 686udjie on 20/11/2026.
//

import Foundation
import Testing

@testable import SwiftyTube

private func artistJSON(_ json: String) -> [String: Any] {
    // swiftlint:disable:next force_try force_cast
    try! JSONSerialization.jsonObject(with: Data(json.utf8)) as! [String: Any]
}

@Suite("YouTube Music artist parser")
struct YouTubeMusicArtistParserTests {
    @Test("Parses the classic music description shelf")
    func classicDescriptionShelf() {
        let json = artistJSON(#"""
        {
          "contents": {
            "singleColumnBrowseResultsRenderer": { "tabs": [{
              "tabRenderer": { "content": { "sectionListRenderer": { "contents": [
                { "musicDescriptionShelfRenderer": {
                  "description": { "runs": [
                    { "text": "First paragraph.\n" },
                    { "text": "Second paragraph." }
                  ] }
                } }
              ] } } }
            }] }
          }
        }
        """#)

        #expect(YouTubeMusicArtistParser.biography(in: json) == "First paragraph.\nSecond paragraph.")
    }

    @Test("Parses a view-model description and ignores unrelated descriptions")
    func viewModelDescription() {
        let json = artistJSON(#"""
        {
          "microformat": { "microformatDataRenderer": {
            "description": "Not the artist biography"
          } },
          "musicDescriptionShelfRenderer": {
            "descriptionPreviewViewModel": {
              "description": { "content": "Artist biography" }
            }
          }
        }
        """#)

        #expect(YouTubeMusicArtistParser.biography(in: json) == "Artist biography")
    }

    @Test("Returns nil when no description shelf exists")
    func missingDescription() {
        #expect(YouTubeMusicArtistParser.biography(in: ["header": [:]]) == nil)
    }
}
