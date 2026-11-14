# SwiftyTube Usage

Every snippet assumes `import SwiftyTube`. This is the shared transport and
infrastructure reference. Surface-specific guides:

- **[YouTube Music](Music.md)** - music home, library, playlists, library sync.
- **[YouTube](YouTube.md)** - feeds, search filters, watch/channel parsing, captions, video playback.

## Client

```swift
let tube = InnerTubeClient(config: .music)   // YouTube Music
let tube = InnerTubeClient(config: .youtube) // YouTube

await tube.updateLocale(YouTubeLocale(gl: "DE", hl: "de")) // change region anytime
```

## Sign-in

```swift
let auth = try SessionImporter.importSession(from: cookieString)
// persist auth.cookies / .sapisid / .visitorData / .dataSyncId your way
await tube.loadState(from: store) // re-call after login/logout; store has 4 getters
```

### Webview sign-in

When a session is captured from a WKWebView instead of a pasted cookie
string, three steps are **required**. Skipping any of them produces a
healthy-looking 200 everywhere while authenticated endpoints (`account/account_menu`,
liked-songs sync) silently answer as an anonymous guest:

```swift
// 1. Present Google's login with the DESKTOP Safari user agent - Google
//    serves a cookie-incomplete mobile flow to mobile UAs.
webView.customUserAgent = LoginWebviewHarvest.userAgent

// 2. Poll for the harvest; do NOT read the cookie store once. The first
//    snapshot after the redirect is incomplete - Google reissues the
//    rotating __Secure-1PSIDTS/3PSIDTS through the redirect chain and the
//    landing page's first seconds.
let session = await LoginWebviewHarvest.collectSession(from: webView)
//    -> (cookies, sapisid); nil after 25s - ask the user to log in again.

// 3. Load it into the client.
await tube.loadState(from: store)
```

Rules `collectSession` (and everything below) are built around:

- The session cookie map is the **youtube.com cookie family only**. Google
  issues one family per auth domain (`.google.com`, `.google.com.hk`, …)
  with different domain-derived values, and a browser never sends
  `.google.com` cookies to a youtube.com host — mixing a google family's
  values into the overlapping youtube names (HSID/SSID/SID/…) makes every
  request answer as anonymous.
- Fresh `__Secure-1PSIDTS`/`__Secure-3PSIDTS` tokens live only in that
  youtube.com family; a session without them is rejected as expired.

### Refreshing a stale session

Google keeps rotating the yt-domain tokens, and a session reconstructed
from a webview too long ago can go stale overnight. Loading
music.youtube.com again does not re-mint anything — only a
**accounts.google.com round trip** does (`SessionTokenRefresher`, same rules
as above, offscreen). Run it once when `account/account_menu` starts
answering guest-shaped with a valid-looking session:

```swift
let reissued = await SessionTokenRefresher.shared.refreshRotatedTokens(baseCookies: savedCookies)
// empty -> re-login needed; otherwise persist `reissued`, re-call
// loadState, and confirm via accountInfo() (should be non-guest now)
```

Keep `shouldContinue` false-able (dismiss/login-already-imported guards) and
always confirm the refresh worked through `accountInfo()` — a guest-shaped
menu is the only visible symptom of any of this going wrong.

## Artwork quality

YouTube serves every size from one URL via a `w<n>-h<n>` hint, and sources
run to ~1400px, so asking up is free. `ArtworkURLs` rewrites thumbnail URLs
for a given pixel size, and exposes a per-surface ladder so each surface
shares one cache entry:

```swift
ArtworkURLs.artwork(url, at: 1200)   // rewrite the hint on a CDN URL
ArtworkURLs.highRes(url)              // same, at the player rung
ArtworkURLs.sized(url, width: 480, height: 480)
ArtworkURLs.rung(for: 450)            // 480 — smallest ladder rung covering it
ArtworkURLs.maxResVariant(url)        // ytimg → maxresdefault (strip ?sqp=…)
ArtworkURLs.sdVariant(url)            // ytimg → sddefault (more likely to exist)
ArtworkURLs.fallback(for: videoId)    // guaranteed hqdefault
```

Rungs: rows 160, cards 480, headers 720, player 1200. Video thumbnails
(ytimg) carry no size hint — swap `hqdefault` via `maxResVariant`/`sdVariant`
instead of rewriting.

## Transport

Raw JSON in, your models out. All calls take optional `client:` / `locale:`
overrides. Browse ids, search filters and parsers differ per surface; see
[Music](Music.md) and [YouTube](YouTube.md).

```swift
let page = try await tube.browse(browseId: browseId)
let page2 = try await tube.browse(continuation: token)
let results = try await tube.search(query: "lofi")
let upNext = try await tube.next(videoId: id, playlistId: playlist) // or next(continuation:)
let typed: PlayerResponse = try await tube.playerResponse(videoId: id)

// Collect all pages instead of handling continuations by hand:
let items = try await tube.paginate(
    browseId: browseId,
    parse: { MyParser.items(from: $0) },
    continuation: { MyParser.token(from: $0) }
)
```

## Comments

Video comments ride the same `/next` transport. Use the **YouTube** config
(`.youtube`, WEB client) — the Music config's default `.webRemix` client does
not return the comments section; you can also force `client: .web` on any call.

### Loading and paging

```swift
// Seed token from the watch page's next response:
let watch = try await tube.next(videoId: id)
let token = CommentsParser.findInitialCommentsToken(in: watch)
// …or YouTubeWatchParser.watch(in: watch, videoId: id).commentsContinuation

let page: CommentsPage = CommentsParser.parseCommentsPage(
    try await tube.next(continuation: token)
)
page.items           // [CommentItem]
page.totalCountText  // "1,234 Comments" (display only)
page.nextPageToken   // feed into tube.next(continuation:) for more
page.sortTokens      // [CommentSort: String] — see Sorting below
page.createCommentParams  // needed to post, nil when signed out
```

`CommentItem` carries the rendered text (`runs` → join with
`CommentsParser.plainText(for:)`), author, `likeCountText`, `replyCount`,
`replyContinuation`, plus the **server-issued action tokens** for mutations
below. All tokens are `nil` for signed-out viewers — YouTube only ships them
on signed-in payloads.

### Sorting

The header hands back one continuation token per sort order; switching sorts
is just another `next(continuation:)`:

```swift
let top = page.sortTokens[.top]        // "Top comments"
let newest = page.sortTokens[.newest]  // "Newest first"

let sorted = CommentsParser.parseCommentsPage(
    try await tube.next(continuation: newest!)
)
```

### Replies

Replies are read-only through this API (there is no reply-posting endpoint
surfaced here). A comment's `replyContinuation` opens its thread:

```swift
if let replyToken = comment.replyContinuation {
    let replies: CommentRepliesPage = CommentsParser.parseRepliesPage(
        try await tube.next(continuation: replyToken)
    )
    replies.items        // [CommentItem], flattened
    replies.nextPageToken  // more replies, same loop
}
```

### Voting (like / dislike)

```swift
// Pick the token matching the transition you want:
let action = direction == .like
    ? (comment.voteState == .liked ? comment.unlikeAction : comment.likeAction)
    : (comment.voteState == .disliked ? comment.undislikeAction : comment.dislikeAction)

let json = try await tube.performCommentAction(action: action!)
let ok = (json["actionResults"] as? [[String: Any]])?.first?["status"] as? String == "STATUS_SUCCEEDED"
// The response carries no framework updates — apply the new
// CommentVoteState (.liked/.disliked/.indifferent) locally.
```

### Posting a comment

```swift
guard let params = page.createCommentParams else { return } // signed out

let json = try await tube.createComment(params: params, text: "Hello!")
if json["showErrorAction"] != nil {
    // rejected (rate limit, empty text, …)
} else if let created = (json["actions"] as? [[String: Any]])?.first?["createCommentAction"] {
    // success — the created comment renderer is in `created`
}
```

`createCommentParams` embeds the video id, so there is no separate target
field. It is only present on the initial comments page (header simplebox),
not on continuation pages.

### Editing and deleting your comments

Both replay tokens from the comment's own menu items; both report success via
`actionResults`:

```swift
// Edit — `editParams` comes from the Edit menu item:
let json = try await tube.updateComment(params: comment.editParams!, text: "Updated text")
let ok = (json["actionResults"] as? [[String: Any]])?.first?["status"] as? String == "STATUS_SUCCEEDED"

// Delete — `deleteAction` is a performComment-action token:
let json2 = try await tube.performCommentAction(action: comment.deleteAction!)
let deleted = (json2["actionResults"] as? [[String: Any]])?.first?["status"] as? String == "STATUS_SUCCEEDED"
```

### Reporting a comment

YouTube's report flow is a multi-step state machine: open the panel, then
advance it with `/flow` until the server returns the confirmation step.

**1. Open the panel** — `reportParams` is the Report menu item's
`showEngagementPanelEndpoint.globalConfiguration.params`:

```swift
let json = try await tube.abuseReportPanel(params: comment.reportParams!)
guard let panel = CommentsParser.parseReportPanel(json) else { return }
// panel.reasons            — [CommentReportReason] (key + localized text + command)
// panel.flowState          — the flow-state entity to echo back on every /flow call
// panel.flowStateEntityKey — its key
// panel.flowId / .targetId — route (both "abuse_report_flow" in practice)
```

**2. Select a reason** (mutate the entity locally, exactly like the web's
radio handler — the POST happens on submit):

```swift
guard var abuse = panel.flowState["abuseReportFlowState"] as? [String: Any] else { return }
let reason = panel.reasons.first { $0.key == "SPAM" }! // SEXUAL, VIOLENCE, HATE,
                                                        // HARASSMENT, DANGEROUS,
                                                        // SUICIDE_SELF_HARM_OR_EATING_DISORDERS,
                                                        // MISINFORMATION, CHILD_ABUSE,
                                                        // TERRORISM, SPAM
abuse["reasonKey"] = reason.key                    // required — 400 INVALID_ARGUMENT without
abuse["navigationEnabled"] = true
abuse["isReportFormDirty"] = true
abuse["navigationCommand"] = reason.command        // the step's getFlowCommand
var state = panel.flowState
state["abuseReportFlowState"] = abuse
```

**3. Advance the flow:**

```swift
let update = CommentsParser.parseReportFlowUpdate(
    try await tube.abuseReportFlow(
        flowState: state,
        flowStateEntityKey: panel.flowStateEntityKey,
        flowId: panel.flowId,
        targetId: panel.targetId
    )
)
```

`update.outcome` is one of:

- `.steps([[String: Any]])` — advanced; classify each (unwrapped) step with
  `CommentsParser.parseReportStep(_:)` → `step.page`:
  - `.reasons` — reason list (also what the panel returns first)
  - `.details(CommentReportDetailsPage)` — optional free-text step; read
    `abuse` from the current `state["abuseReportFlowState"]`, set
    `abuse["userComments"] = text` (respect `page.maxChars`), then assign it
    back to `state["abuseReportFlowState"]` alongside
    `state["flowFormState"] = ["isValid": true]` before the next advance
  - `.confirmation` — **the report was accepted**; stop here
  - `.signIn` — YouTube wants a session
- `.failure(String?)` — the server rejected our state; carries its toast text
  (e.g. `"Something went wrong. Try again later."` when signed out)
- `.noOp` — 200 without an `updateFlowCommand`; the state wasn't accepted

```swift
if case .details(let page) = step.page,
   var abuse = state["abuseReportFlowState"] as? [String: Any] {
    abuse["userComments"] = String(text.prefix(page.maxChars))
    state["abuseReportFlowState"] = abuse
    state["flowFormState"] = ["isValid": true]
}
```

After each advance, adopt the replacement entity and re-read its route:

```swift
if let newState = update.flowState {
    state = newState
    if let key = update.flowStateEntityKey { /* use for the next call */ }
    if let abuse = state["abuseReportFlowState"] as? [String: Any],
       let command = abuse["navigationCommand"] as? [String: Any], !command.isEmpty {
        let route = CommentsParser.flowRoute(from: command) // (flowId, targetId)
    }
}
// Prefer the step matching state["currentStepId"]; fall back to the last step.
```

The panel call works signed-out (YouTube gates the submission server-side and
answers the first `/flow` with a toast instead).

## Play a stream

Walks the fallback chain, mints PoTokens lazily, validates, caches - returns the first working stream:

```swift
var request = StreamResolveRequest.playback(videoId: id)
request.options.audioQuality = .high
let result = try await StreamFallback.resolveFirstValid(
    request, using: tube, providers: .live
)
// result.streamUrl, .title, .author, .duration, .loudnessDb, ...

let download = StreamResolveRequest.download(videoId: id) // no cache, AAC preferred
```

`.live` wires the shared cipher fetcher, WebView, config store, and format tracking. Add yours:

```swift
var providers = StreamResolveProviders.live
providers.poTokenProvider = { videoId in
    try? await PoTokenGenerator.shared.generate(videoId: videoId, sessionId: mySessionId)
}
providers.resolvedFormatHandler = { info in
    // persist info.itag / .mimeType / .playbackUrl for tracking
}
```

One client, no loop:

```swift
let result = try await StreamResolver.resolve(
    videoId: id, client: .androidVr1_65_10, using: tube, providers: providers
)
let ok = await StreamResolver.validateStream(url: result.streamUrl)
```

## Durations

Never throws - cached value, fresh fetch, or nil while another task fetches:

```swift
if let seconds = await tube.resolveDuration(videoId: id) { ... }
// completion posts NotificationCenter .durationDidUpdate with ["videoId": id]
```

## PoTokens and cipher (standalone)

```swift
let tokens = try await PoTokenGenerator.shared.generate(videoId: id, sessionId: sid)
// tokens.playerRequestPoToken → /player body, .streamingDataPoToken → &pot=

let sts = try await PlayerJsFetcher.shared.getSignatureTimestamp()
let url = try await CipherExecutor.shared.resolveCipherURL(
    cipherText: cipher, playerJs: js, playerHash: nil
)
let config = await PlayerConfigStore.shared.config(for: hash)
```

`po_token.html` ships with the package; apps with their own copy keep working as a fallback.

## Parsing helpers

Nil instead of crashes:

```swift
InnerTubeJSON.runsText(dict)              // joined runs, falls back to simpleText
InnerTubeJSON.runsTexts(dict)             // all run texts minus separators
InnerTubeJSON.lastThumbnailURL(list)      // largest thumbnail
InnerTubeDecode.dict(at: ["contents", "x"], in: json)
InnerTubeDecode.string(at: [...], in: json)
InnerTubeDecode.intFromStringOrInt(value) // String-or-Int fields
InnerTubeDecode.continuationToken(in: shelf)
```

## Keychain, HTTP, logging

```swift
let store = SecureStore(service: "com.myapp.session")
try store.save(data, for: "key")
let data = try store.load(for: "key") // throws .notFound when missing

let (data, response) = try await HttpClient.validatedData(for: request)
try await RetryPolicy.innerTube.run({ try await fetch() }, isRetryable: { _ in true })

SwiftyTubeLog.handler = { message, level in myLogger.log("\(level): \(message)") }
// default forwards to os.Logger, subsystem "SwiftyTube"
```
