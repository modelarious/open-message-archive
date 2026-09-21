# Plan

## Gate 0 — clean-room feasibility — VERIFIED

Verified from public sources:

- Apple added Messages **Find Message** and **Find Conversation** to Shortcuts in iOS 26.
- TextPort publicly documents that its iPhone Messages import is performed by an Apple Shortcut because an ordinary app cannot read Messages directly.
- Apple App Intents supports receiving file content through `IntentFile`.
- Therefore an independent, public/system-API architecture exists without a backend.

## Gate 1 — portable archive/export core — VERIFIED

Merged on `main` and exercised by clean GitHub Actions:

- canonical Codable archive model
- deterministic JSON
- TXT renderer
- CSV renderer
- self-contained HTML renderer
- round-trip, chronology, CSV quoting and HTML escaping tests

## Gate 2 — iOS application shell — COMPILE-VERIFIED

The SwiftUI application and App Intent compile under Xcode 26.6 on GitHub's macOS 26 runner:

- SwiftUI local import/export UI
- atomic local output
- App Intent accepting a JSON `IntentFile`
- separate iOS core framework target
- XcodeGen reproducible project specification
- CI builds a generic iOS Simulator target with code signing disabled

This proves the app target is valid Swift/Xcode code. It does **not** prove Messages-history access.

## Gate 3 — companion Shortcut — IN PROGRESS

The clean-room Shortcut must use only Apple-visible actions. Publicly established pieces:

- Messages: Find Conversation
- Messages: Find Message
- message properties including body, sender, date, conversation and attachments
- normal Shortcuts list/dictionary/file actions
- the app's Import Conversation Archive App Intent

Remaining implementation detail: reproduce Apple's exact serialization for a dynamic Conversation entity filter without copying a proprietary Shortcut.

Then, on a non-critical physical iPhone running iOS 26+:

- import a synthetic one-to-one conversation;
- compare exact known message count, bodies, dates, senders and order;
- test Unicode/multiline messages;
- stress-test long histories and explicit error behavior;
- confirm the Shortcut performs no message mutations.

## Gate 4 — attachments

Prove photos/video/audio/files can be moved through the Shortcut boundary without silent omissions. TextPort's public documentation independently confirms an important platform constraint: Shortcuts can only read attachments currently downloaded to the phone; older iCloud-only attachments must be downloaded in Messages first.

Preserve originals where possible and hash copied files. Missing media must remain explicit, never silently disappear.

## Gate 5 — batch transaction

Enumerate selected conversations, import them one at a time, stage all exports locally, verify manifest counts/hashes, then expose the completed archive directory through the share sheet.

Cloud/File Provider destinations are post-export destinations only. The export is never streamed directly into Google Drive, Dropbox or another provider.

## Gate 6 — PDF

Render archival PDF from the same canonical model. PDF is an output view, never the sole stored representation.

## Gate 7 — release

- accessibility and Dynamic Type pass
- privacy manifest
- no analytics, ads, account requirement or hosted backend
- reproducible build instructions
- App Store privacy declaration consistent with code
- external beta on non-critical devices
- App Review
- permanent free App Store listing

## Current blocker

A physical iPhone running iOS 26+ that is safe to use for synthetic test conversations is required before the Messages import path can be marked VERIFIED. The bereaved family's phone is explicitly **not** a development/test device.

Apple Developer Program membership for distribution has not yet been verified.
