//
//  YouTubeShortsParser.swift
//  SwiftyTube
//
//  Created by 686udjie on 28/11/2026.
//

import Foundation

extension InnerTubeClient {
    /// The Shorts feed (`reel/reel_watch_sequence`). Without a token it starts
    /// a fresh sequence; a fresh sequence holds only a single Short, so when
    /// the first page is tiny the real feed's continuation is fetched and
    /// merged automatically.
    public func shorts(
        continuation: String? = nil,
        client: YouTubeClient? = nil
    ) async throws -> YouTubeShortsPage {
        let body: [String: Any] = [
            "context": contextDict(client: client, locale: nil),
            "sequenceParams": continuation ?? "CA8%3D"
        ]
        let json = try await post(endpoint: "reel/reel_watch_sequence", body: body, client: client)
        let page = YouTubeFeedParser.shortsSequence(in: json)
        guard continuation == nil,
              page.videoIds.count <= 3,
              let next = page.continuation else {
            return page
        }
        let more = try await shorts(continuation: next, client: client)
        var ids = page.videoIds
        var seen = Set(ids)
        for id in more.videoIds where seen.insert(id).inserted {
            ids.append(id)
        }
        return YouTubeShortsPage(videoIds: ids, continuation: more.continuation)
    }
}
