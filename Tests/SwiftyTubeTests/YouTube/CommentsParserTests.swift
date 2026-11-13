//
//  CommentsParserTests.swift
//  SwiftyTubeTests
//
//  Created by 686udjie on 13/11/2026.
//

import Foundation
import Testing

@testable import SwiftyTube

private func jsonObject(_ json: String) -> [String: Any] {
    // swiftlint:disable:next force_try force_cast
    try! JSONSerialization.jsonObject(with: Data(json.utf8)) as! [String: Any]
}

@Suite("Comments parser")
struct CommentsParserTests {
    private let signedInJSON = jsonObject(#"""
    {
      "onResponseReceivedEndpoints": [
        { "appendContinuationItemsAction": { "continuationItems": [
          { "commentThreadRenderer": {
              "commentViewModel": { "commentViewModel": {
                "commentId": "UgwIN0000000000000001",
                "toolbarStateKey": "state-key-1",
                "toolbarSurfaceKey": "surface-key-1"
              }}
          }},
          { "continuationItemRenderer": { "continuationEndpoint": {
              "continuationCommand": { "token": "Eg0SC3BhZ2VUb2tlbl8xMjM0NTY3ODkw" }
          }}}
        ]}}
      ],
      "frameworkUpdates": { "entityBatchUpdate": { "mutations": [
        { "payload": { "commentEntityPayload": {
            "key": "comment-key-1",
            "author": { "displayName": "Somebody", "isVerified": true },
            "properties": {
              "commentId": "UgwIN0000000000000001",
              "content": { "content": "Great song!" },
              "publishedTime": "2 days ago",
              "toolbarStateKey": "state-key-1"
            },
            "toolbar": {
              "likeCountNotliked": "11",
              "likeCountLiked": "12",
              "replyCount": "3"
            }
        }}},
        { "payload": { "engagementToolbarStateEntityPayload": {
            "key": "state-key-1",
            "likeState": "TOOLBAR_LIKE_STATE_INDIFFERENT",
            "heartState": "TOOLBAR_HEART_STATE_UNHEARTED"
        }}},
        { "payload": { "engagementToolbarSurfaceEntityPayload": {
            "key": "surface-key-1",
            "isEngagementToolbar": true,
            "likeCommand": { "innertubeCommand": { "performCommentActionEndpoint": {
                "action": "LIKE_TOKEN_1"
            }}},
            "unlikeCommand": { "innertubeCommand": { "performCommentActionEndpoint": {
                "action": "UNLIKE_TOKEN_1"
            }}},
            "dislikeCommand": { "innertubeCommand": { "performCommentActionEndpoint": {
                "action": "DISLIKE_TOKEN_1"
            }}},
            "undislikeCommand": { "innertubeCommand": { "performCommentActionEndpoint": {
                "action": "UNDISLIKE_TOKEN_1"
            }}}
        }}}
      ]}}
    }
    """#)

    private let signedOutJSON = jsonObject(#"""
    {
      "onResponseReceivedEndpoints": [
        { "appendContinuationItemsAction": { "continuationItems": [
          { "commentThreadRenderer": {
              "commentViewModel": { "commentViewModel": {
                "commentId": "UgwOUT000000000000001",
                "toolbarStateKey": "state-key-out",
                "toolbarSurfaceKey": "surface-key-out"
              }}
          }}
        ]}}
      ],
      "frameworkUpdates": { "entityBatchUpdate": { "mutations": [
        { "payload": { "commentEntityPayload": {
            "properties": {
              "commentId": "UgwOUT000000000000001",
              "content": { "content": "First!" },
              "publishedTime": "1 day ago",
              "toolbarStateKey": "state-key-out"
            },
            "toolbar": { "likeCountNotliked": "5", "likeCountLiked": "6" }
        }}},
        { "payload": { "engagementToolbarStateEntityPayload": {
            "key": "state-key-out",
            "likeState": "TOOLBAR_LIKE_STATE_INDIFFERENT",
            "heartState": "TOOLBAR_HEART_STATE_UNHEARTED"
        }}},
        { "payload": { "engagementToolbarSurfaceEntityPayload": {
            "key": "surface-key-out",
            "isEngagementToolbar": true,
            "prepareAccountCommand": { "innertubeCommand": { "modalEndpoint": {} } },
            "likeCommand": { "innertubeCommand": { "clickTrackingParams": "CAAQ" } },
            "unlikeCommand": { "innertubeCommand": { "clickTrackingParams": "CAAQ" } },
            "dislikeCommand": { "innertubeCommand": { "clickTrackingParams": "CAAQ" } },
            "undislikeCommand": { "innertubeCommand": { "clickTrackingParams": "CAAQ" } }
        }}}
      ]}}
    }
    """#)

    private let signedInRepliesJSON = jsonObject(#"""
    {
      "onResponseReceivedEndpoints": [
        { "appendContinuationItemsAction": { "continuationItems": [
          { "commentViewModel": { "commentViewModel": {
              "commentId": "UgwREP000000000000001",
              "toolbarStateKey": "state-key-rep",
              "toolbarSurfaceKey": "surface-key-rep"
          }}},
          { "continuationItemRenderer": { "continuationEndpoint": {
              "continuationCommand": { "token": "Eg0SC3JlcGx5VG9rZW5fOTg3NjU0MzIxMA" }
          }}}
        ]}}
      ],
      "frameworkUpdates": { "entityBatchUpdate": { "mutations": [
        { "payload": { "commentEntityPayload": {
            "properties": {
              "commentId": "UgwREP000000000000001",
              "content": { "content": "Reply body" },
              "publishedTime": "3 hours ago",
              "replyLevel": 1,
              "toolbarStateKey": "state-key-rep"
            },
            "toolbar": { "likeCountNotliked": "11", "likeCountLiked": "12" }
        }}},
        { "payload": { "engagementToolbarStateEntityPayload": {
            "key": "state-key-rep",
            "likeState": "TOOLBAR_LIKE_STATE_LIKED",
            "heartState": "TOOLBAR_HEART_STATE_UNHEARTED"
        }}},
        { "payload": { "engagementToolbarSurfaceEntityPayload": {
            "key": "surface-key-rep",
            "isEngagementToolbar": true,
            "likeCommand": { "innertubeCommand": { "performCommentActionEndpoint": {
                "action": "LIKE_TOKEN_REP"
            }}},
            "unlikeCommand": { "innertubeCommand": { "performCommentActionEndpoint": {
                "action": "UNLIKE_TOKEN_REP"
            }}},
            "dislikeCommand": { "innertubeCommand": { "performCommentActionEndpoint": {
                "action": "DISLIKE_TOKEN_REP"
            }}},
            "undislikeCommand": { "innertubeCommand": { "performCommentActionEndpoint": {
                "action": "UNDISLIKE_TOKEN_REP"
            }}}
        }}}
      ]}}
    }
    """#)

    @Test("Signed-in thread exposes all four action tokens")
    func signedInTokens() {
        let page = CommentsParser.parseCommentsPage(signedInJSON)
        #expect(page.items.count == 1)
        let comment = page.items[0]
        #expect(comment.id == "UgwIN0000000000000001")
        #expect(comment.likeAction == "LIKE_TOKEN_1")
        #expect(comment.unlikeAction == "UNLIKE_TOKEN_1")
        #expect(comment.dislikeAction == "DISLIKE_TOKEN_1")
        #expect(comment.undislikeAction == "UNDISLIKE_TOKEN_1")
        #expect(comment.voteState == .indifferent)
        #expect(comment.likeCountText == "11")
        #expect(comment.replyCount == 3)
        #expect(comment.replyCountText == "3")
        #expect(comment.author.name == "Somebody")
        #expect(comment.author.isVerified)
        #expect(page.nextPageToken == "Eg0SC3BhZ2VUb2tlbl8xMjM0NTY3ODkw")
    }

    @Test("Signed-out toolbar carries no action tokens")
    func signedOutTokens() {
        let page = CommentsParser.parseCommentsPage(signedOutJSON)
        #expect(page.items.count == 1)
        let comment = page.items[0]
        #expect(comment.likeAction == nil)
        #expect(comment.unlikeAction == nil)
        #expect(comment.dislikeAction == nil)
        #expect(comment.undislikeAction == nil)
        #expect(comment.voteState == .indifferent)
        #expect(comment.likeCountText == "5")
    }

    @Test("Liked reply reports liked state, liked count, and its tokens")
    func likedReply() {
        let page = CommentsParser.parseRepliesPage(signedInRepliesJSON)
        #expect(page.items.count == 1)
        let reply = page.items[0]
        #expect(reply.id == "UgwREP000000000000001")
        #expect(reply.voteState == .liked)
        #expect(reply.likeCountText == "12")
        #expect(reply.likeAction == "LIKE_TOKEN_REP")
        #expect(reply.unlikeAction == "UNLIKE_TOKEN_REP")
        #expect(reply.dislikeAction == "DISLIKE_TOKEN_REP")
        #expect(reply.undislikeAction == "UNDISLIKE_TOKEN_REP")
        #expect(reply.replyCount == 0)
        #expect(reply.replyCountText == "")
        #expect(page.nextPageToken == "Eg0SC3JlcGx5VG9rZW5fOTg3NjU0MzIxMA")
    }
}
