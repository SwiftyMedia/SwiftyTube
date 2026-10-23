//
//  AccountMenuTests.swift
//  SwiftyTubeTests
//
//  Created by 686udjie on 23/10/2026.
//

import Foundation
import Testing

@testable import SwiftyTube

// Fixtures for the two `account/account_menu` envelopes.

private func runsHeader(_ accountName: String, email: String? = nil) -> [String: Any] {
    var renderer: [String: Any] = [
        "accountName": ["runs": [["text": accountName]]],
        "accountPhoto": ["thumbnails": [["url": "https://x/p.jpg"]]]
    ]
    if let email {
        renderer["email"] = ["runs": [["text": email]]]
    }
    return renderer
}

@Suite("Account menu session probe")
struct AccountMenuTests {
    @Test("Chrome menu shape (activeAccountHeaderRenderer) verifies signed in")
    func chromeMenu() {
        let json: [String: Any] = [
            "actions": [
                ["openPopupAction": [
                    "popup": ["multiPageMenuRenderer": [
                        "header": ["activeAccountHeaderRenderer": runsHeader("Test User", email: "t@example.com")]
                    ]]
                ]]
            ]
        ]
        let identity = BrowseLens.signedInAccount(json)
        #expect(identity?.name == "Test User")
        #expect(identity?.email == "t@example.com")
        #expect(identity?.hasPhoto == true)
    }

    @Test("musicMultiPageMenuRenderer popup variant verifies signed in")
    func musicPopupVariant() {
        let json: [String: Any] = [
            "actions": [
                ["openPopupAction": [
                    "popup": ["musicMultiPageMenuRenderer": [
                        "header": ["activeAccountHeaderRenderer": ["accountName": ["runs": [["text": "YTM User"]]]]]
                    ]]
                ]]
            ]
        ]
        #expect(BrowseLens.signedInAccount(json)?.name == "YTM User")
    }

    @Test("Legacy top-level musicAccountHeaderRenderer verifies signed in")
    func legacyHeader() {
        let json: [String: Any] = ["header": ["musicAccountHeaderRenderer": runsHeader("Legacy User")]]
        #expect(BrowseLens.signedInAccount(json)?.name == "Legacy User")
    }

    @Test("simpleText fields resolve too")
    func simpleTextVariant() {
        let json: [String: Any] = [
            "header": ["musicAccountHeaderRenderer": [
                "accountName": ["simpleText": "Simple User"],
                "email": ["simpleText": "s@example.com"]
            ]]
        ]
        let identity = BrowseLens.signedInAccount(json)
        #expect(identity?.name == "Simple User")
        #expect(identity?.email == "s@example.com")
    }

    @Test("Signed-out menu (no account header) verifies not signed in")
    func signedOutMenu() {
        let json: [String: Any] = [
            "actions": [
                ["openPopupAction": [
                    "popup": ["multiPageMenuRenderer": [
                        "sections": [
                            ["multiPageMenuSectionRenderer": [
                                "items": [["signInButtonRenderer": ["text": ["runs": [["text": "Sign in"]]]]]]
                            ]]
                        ]
                    ]]
                ]]
            ]
        ]
        #expect(BrowseLens.signedInAccount(json) == nil)
    }
}
