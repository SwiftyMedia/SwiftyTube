//
//  YouTubeMusicArtistParser.swift
//  SwiftyTube
//
//  Created by 686udjie on 20/11/2026.
//

import Foundation

/// Parses artist metadata returned by a YouTube Music `browse` response.
public enum YouTubeMusicArtistParser: Sendable {
    /// Returns the artist biography from the YouTube Music description shelf.
    ///
    /// YouTube Music has shipped both the classic
    /// `musicDescriptionShelfRenderer` shape and newer view-model based
    /// descriptions. Only known description renderers are considered so an
    /// unrelated page description cannot be mistaken for the artist bio.
    public static func biography(in json: [String: Any]) -> String? {
        var biography: String?

        YouTubeFeedParser.walk(json) { renderer, key in
            guard biography == nil,
                  key == "musicDescriptionShelfRenderer"
                    || key == "descriptionShelfRenderer" else { return }
            biography = descriptionText(in: renderer)
        }

        return normalized(biography)
    }

    private static func descriptionText(in renderer: [String: Any]) -> String? {
        if let text = InnerTubeJSON.runsText(renderer["description"] as? [String: Any]) {
            return text
        }
        if let text = InnerTubeJSON.runsText(renderer["descriptionText"] as? [String: Any]) {
            return text
        }
        if let text = renderer["description"] as? String {
            return text
        }
        if let text = InnerTubeDecode.string(
            at: ["description", "descriptionPreviewViewModel", "description", "content"],
            in: renderer
        ) {
            return text
        }
        return InnerTubeDecode.string(
            at: ["descriptionPreviewViewModel", "description", "content"],
            in: renderer
        )
    }

    private static func normalized(_ text: String?) -> String? {
        guard let text else { return nil }
        let value = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
