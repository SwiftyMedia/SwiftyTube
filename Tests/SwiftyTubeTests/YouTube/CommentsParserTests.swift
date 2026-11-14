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

    private let headerJSON = jsonObject(#"""
    {
      "onResponseReceivedEndpoints": [
        { "reloadContinuationItemsCommand": { "continuationItems": [
          { "commentsHeaderRenderer": {
              "countText": { "runs": [{ "text": "2,661" }, { "text": " Comments" }] },
              "createRenderer": { "commentSimpleboxRenderer": {
                  "submitButton": { "buttonRenderer": {
                      "serviceEndpoint": { "createCommentEndpoint": {
                          "createCommentParams": "EgtPMURhYmVNUno1SSoCCABQB-gCAagDAA%3D%3D"
                      }}
                  }}
              }}
          }}
        ]}}
      ]
    }
    """#)

    private let signedOutHeaderJSON = jsonObject(#"""
    {
      "onResponseReceivedEndpoints": [
        { "reloadContinuationItemsCommand": { "continuationItems": [
          { "commentsHeaderRenderer": {
              "countText": { "runs": [{ "text": "42" }, { "text": " Comments" }] }
          }}
        ]}}
      ]
    }
    """#)

    @Test("Comments header exposes createCommentParams when signed in")
    func createCommentParams() {
        let page = CommentsParser.parseCommentsPage(headerJSON)
        #expect(page.createCommentParams == "EgtPMURhYmVNUno1SSoCCABQB-gCAagDAA%3D%3D")
        #expect(page.totalCountText == "2,661")
        #expect(page.items.isEmpty)
    }

    @Test("Signed-out header carries no createCommentParams")
    func signedOutCreateParams() {
        let page = CommentsParser.parseCommentsPage(signedOutHeaderJSON)
        #expect(page.createCommentParams == nil)
    }

    /// One signed-in comment whose toolbar surface carries `surface` —
    /// keeps the menu-shape variants from repeating a whole page fixture.
    private func page(
        withSurface surface: String,
        author: String = #""displayName": "Me""#,
        entityExtra: String = ""
    ) -> [String: Any] {
        jsonObject(#"""
        {
          "onResponseReceivedEndpoints": [
            { "appendContinuationItemsAction": { "continuationItems": [
              { "commentThreadRenderer": { "commentViewModel": { "commentViewModel": {
                  "commentId": "UgwIN0000000000000009",
                  "toolbarStateKey": "state-key-9",
                  "toolbarSurfaceKey": "surface-key-9"
              }}}}
            ]}}
          ],
          "frameworkUpdates": { "entityBatchUpdate": { "mutations": [
            { "payload": { "commentEntityPayload": {
                "key": "comment-key-9",
                "author": { \#(author) },
                "properties": {
                  "commentId": "UgwIN0000000000000009",
                  "content": { "content": "My own comment" },
                  "publishedTime": "1 day ago",
                  "toolbarStateKey": "state-key-9"
                },
                \#(entityExtra)
                "toolbar": { "likeCountNotliked": "0" }
            }}},
            { "payload": { "engagementToolbarSurfaceEntityPayload": {
                "key": "surface-key-9",
                \#(surface)
            }}}
          ]}}
        }
        """#)
    }

    private let ownDeleteMenu = #"""
    "likeCommand": { "innertubeCommand": { "performCommentActionEndpoint": { "action": "LIKE_TOKEN_9" } }},
    "menuCommand": { "innertubeCommand": { "menuEndpoint": { "menu": { "menuRenderer": { "items": [
      { "menuServiceItemRenderer": {
          "text": { "runs": [{ "text": "Delete" }] },
          "icon": { "iconType": "DELETE" },
          "serviceEndpoint": { "performCommentActionEndpoint": { "action": "DELETE_TOKEN_9" } }
      }}
    ]}}}}}
    """#

    /// Mirrors the live own-comment menu: an Edit navigation item first
    /// (its submit button carries `updateCommentParams`), then Delete
    /// behind YouTube's confirm dialog under `navigationEndpoint.content`.
    private let confirmDialogDeleteMenu = #"""
    "menuCommand": { "innertubeCommand": { "menuEndpoint": { "menu": { "menuRenderer": { "items": [
      { "menuNavigationItemRenderer": {
          "icon": { "iconType": "EDIT" },
          "text": { "runs": [{ "text": "Edit" }] },
          "navigationEndpoint": { "updateCommentDialogEndpoint": { "dialog": { "commentDialogRenderer": {
              "editableText": { "runs": [{ "text": "My own comment" }] },
              "submitButton": { "buttonRenderer": { "serviceEndpoint": {
                  "commandMetadata": { "webCommandMetadata": { "apiUrl": "/youtubei/v1/comment/update_comment" }},
                  "updateCommentEndpoint": { "updateCommentParams": "EDIT_PARAMS_CD" }
              }}}
          }}}}
      }},
      { "menuNavigationItemRenderer": {
          "icon": { "iconType": "DELETE" },
          "text": { "runs": [{ "text": "Delete" }] },
          "navigationEndpoint": { "confirmDialogEndpoint": { "content": { "confirmDialogRenderer": {
              "confirmButton": { "buttonRenderer": { "serviceEndpoint": {
                  "performCommentActionEndpoint": { "action": "DELETE_TOKEN_CD" }
              }}}
          }}}}
      }}
    ]}}}}}
    """#

    private let reportOnlyMenu = #"""
    "menuCommand": { "innertubeCommand": { "menuEndpoint": { "menu": { "menuRenderer": { "items": [
      { "menuServiceItemRenderer": {
          "text": { "runs": [{ "text": "Report" }] },
          "icon": { "iconType": "FLAG" },
          "serviceEndpoint": { "showEngagementPanelEndpoint": { "identifier": { "tag": "PAabuse_report" } } }
      }}
    ]}}}}}
    """#

    @Test("Own comment exposes a delete token from its menu")
    func deleteToken() {
        let parsed = CommentsParser.parseCommentsPage(page(withSurface: ownDeleteMenu))
        #expect(parsed.items.count == 1)
        #expect(parsed.items[0].deleteAction == "DELETE_TOKEN_9")
        #expect(parsed.items[0].likeAction == "LIKE_TOKEN_9")
    }

    @Test("Delete behind a confirm dialog still yields the token")
    func deleteTokenBehindConfirmDialog() {
        let parsed = CommentsParser.parseCommentsPage(page(withSurface: confirmDialogDeleteMenu))
        #expect(parsed.items[0].deleteAction == "DELETE_TOKEN_CD")
    }

    @Test("Edit item yields updateCommentParams alongside the delete token")
    func editParamsFromMenu() {
        let parsed = CommentsParser.parseCommentsPage(page(withSurface: confirmDialogDeleteMenu))
        #expect(parsed.items[0].editParams == "EDIT_PARAMS_CD")
    }

    @Test("Other people's menus (Report only) carry no edit params")
    func reportOnlyMenuHasNoEditParams() {
        let parsed = CommentsParser.parseCommentsPage(page(withSurface: reportOnlyMenu))
        #expect(parsed.items[0].editParams == nil)
    }

    @Test("Other people's menus (Report only) carry no delete token")
    func reportOnlyMenuHasNoDeleteToken() {
        let parsed = CommentsParser.parseCommentsPage(page(withSurface: reportOnlyMenu))
        #expect(parsed.items[0].deleteAction == nil)
    }

    @Test("Any action-bearing menu item yields a token when no Delete label matches")
    func unlabeledActionMenuFallsBackToToken() {
        let surface = #"""
        "menuCommand": { "innertubeCommand": { "menuEndpoint": { "menu": { "menuRenderer": { "items": [
          { "menuServiceItemRenderer": {
              "text": { "runs": [{ "text": "Supprimer" }] },
              "serviceEndpoint": { "performCommentActionEndpoint": { "action": "DELETE_TOKEN_U" } }
          }}
        ]}}}}}
        """#
        let parsed = CommentsParser.parseCommentsPage(page(withSurface: surface))
        #expect(parsed.items[0].deleteAction == "DELETE_TOKEN_U")
    }

    @Test("Menu on the comment entity itself still yields the delete token")
    func entityLevelMenu() {
        let entityExtra = #"""
        "actionMenu": { "menuRenderer": { "items": [
          { "menuServiceItemRenderer": {
              "text": { "runs": [{ "text": "Delete" }] },
              "serviceEndpoint": { "performCommentActionEndpoint": { "action": "DELETE_TOKEN_E" } }
          }}
        ]}},
        """#
        let parsed = CommentsParser.parseCommentsPage(
            page(withSurface: #""isEngagementToolbar": true"#, entityExtra: entityExtra)
        )
        #expect(parsed.items[0].deleteAction == "DELETE_TOKEN_E")
    }

    @Test("Author channel URL prefers the canonical channel id over a handle")
    func authorPrefersChannelId() {
        let author = #"""
        "displayName": "Me",
        "channelId": "UCfakes0123456789abcdef",
        "channelCommand": { "innertubeCommand": { "commandMetadata": { "webCommandMetadata": {
            "url": "/@somehandle"
        }}}}
        """#
        let parsed = CommentsParser.parseCommentsPage(page(withSurface: ownDeleteMenu, author: author))
        #expect(parsed.items[0].author.channelURL?.hasSuffix("/channel/UCfakes0123456789abcdef") == true)
    }

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
        #expect(comment.deleteAction == nil)
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

    // MARK: - Report flow

    /// Trimmed copy of a real signed-in `/flow` success: `steps` and the
    /// flow-state entity sit nested inside `commandExecutorCommand`, with
    /// `entityUpdateCommand` double-wrapped, next to `hideReportedCommentAction`.
    private let flowSuccessJSON = jsonObject(#"""
    {
      "updateFlowCommand": {
        "clickTrackingParams": "CP",
        "commandExecutorCommand": { "commands": [
          { "clickTrackingParams": "CP",
            "hideReportedCommentAction": { "commentId": "UgzJcHErld7NVaCUZhl4AaABAg" } },
          { "clickTrackingParams": "CP", "updateFlowCommand": {
              "entityUpdateCommand": {
                "clickTrackingParams": "CP",
                "entityUpdateCommand": { "entityBatchUpdate": { "mutations": [
                  { "entityKey": "STATE_KEY_1",
                    "type": "ENTITY_MUTATION_TYPE_REPLACE",
                    "payload": { "flowStateEntity": {
                        "key": "STATE_KEY_1",
                        "currentStepId": "confirmation_page_step",
                        "stepIdStack": ["reason_select_page_step", "confirmation_page_step"],
                        "abuseReportFlowState": {
                          "reasonKey": "DANGEROUS",
                          "navigationEnabled": true,
                          "isReportFormDirty": true
                        }
                    }}}
                ]}}
              },
              "steps": [
                { "flowStepRenderer": {
                    "stepId": "confirmation_page_step",
                    "content": { "reportFormConfirmationPageViewModel": {
                        "confirmationHeader": "Thanks for helping our community",
                        "confirmationText": { "content": "Your report helps us protect the community." },
                        "whatToExpectHeader": "What you can expect",
                        "nextSteps": [
                          { "iconName": "NOT_INTERESTED",
                            "text": { "content": "We may temporarily restrict their comments." } }
                        ]
                    }},
                    "bottomBar": { "reportFormBottomBarViewModel": {
                        "flowStateKey": "STATE_KEY_1",
                        "navButton": { "buttonViewModel": { "title": "OK" } }
                    }}
                }}
              ],
              "targetId": "abuse_report_flow"
          }}
        ]}
      }
    }
    """#)

    /// Signed-out rejection: the executor only carries a toast + panel close.
    private let flowFailureJSON = jsonObject(#"""
    {
      "updateFlowCommand": {
        "clickTrackingParams": "CP",
        "commandExecutorCommand": { "commands": [
          { "clickTrackingParams": "CP",
            "openPopupAction": {
              "popup": { "notificationActionRenderer": {
                  "responseText": { "runs": [{ "text": "Something went wrong. Try again later." }] }
              }},
              "popupType": "TOAST"
            }
          },
          { "clickTrackingParams": "CP",
            "hideEngagementPanelEndpoint": {
              "identifier": { "tag": "PAabuse_report" },
              "isGlobalPanel": true
            }
          }
        ]}
      }
    }
    """#)

    @Test("Nested success payload yields the confirmation step and new flow state")
    func flowSuccessNestedSteps() {
        let update = CommentsParser.parseReportFlowUpdate(flowSuccessJSON)
        guard case .steps(let steps) = update.outcome else {
            Issue.record("expected .steps, got \(update.outcome)")
            return
        }
        #expect(steps.count == 1)

        let step = CommentsParser.parseReportStep(steps[0])
        #expect(step.stepId == "confirmation_page_step")
        #expect(step.navTitle == "OK")
        guard case .confirmation(let page) = step.page else {
            Issue.record("expected confirmation page, got \(step.page)")
            return
        }
        #expect(page.header == "Thanks for helping our community")
        #expect(page.whatToExpectHeader == "What you can expect")
        #expect(page.nextSteps.count == 1)
        #expect(page.nextSteps[0].iconName == "NOT_INTERESTED")

        #expect(update.flowStateEntityKey == "STATE_KEY_1")
        #expect((update.flowState?["currentStepId"] as? String) == "confirmation_page_step")
        let abuse = update.flowState?["abuseReportFlowState"] as? [String: Any]
        #expect(abuse?["reasonKey"] as? String == "DANGEROUS")
    }

    @Test("Rejection toast surfaces the server's failure message")
    func flowFailureToast() {
        let update = CommentsParser.parseReportFlowUpdate(flowFailureJSON)
        guard case .failure(let message) = update.outcome else {
            Issue.record("expected .failure, got \(update.outcome)")
            return
        }
        #expect(message == "Something went wrong. Try again later.")
    }

    @Test("Response without updateFlowCommand is a no-op")
    func flowWithoutUpdateIsNoOp() {
        let update = CommentsParser.parseReportFlowUpdate(jsonObject(#"{ "responseContext": {} }"#))
        guard case .noOp = update.outcome else {
            Issue.record("expected .noOp, got \(update.outcome)")
            return
        }
    }
}
