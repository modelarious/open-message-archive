# Plan

## Gate 0 — clean-room feasibility — PASS

Verified from public sources:

- Apple added Messages **Find Message** and **Find Conversation** to Shortcuts in iOS 26.
- A shipping App Store product publicly documents using a Shortcut as its Messages-reading boundary.
- Apple App Intents supports receiving file content through `IntentFile`.
- Therefore an independent, public-API architecture exists without a backend.

## Gate 1 — portable archive/export core — IMPLEMENTED

- canonical Codable archive model
- deterministic JSON
- TXT renderer
- CSV renderer
- self-contained HTML renderer
- unit tests for round-trip and escaping

## Gate 2 — iOS application shell — IMPLEMENTED, UNVERIFIED

- SwiftUI import/export shell
- local atomic output
- App Intent accepting a JSON `IntentFile`
- XcodeGen specification for an iOS 26 target

Blocked from local compilation until Xcode 26 is installed.

## Gate 3 — companion Shortcut — NEXT

On a non-critical physical iPhone running iOS 26+:

- build the Shortcut from Apple actions;
- pass one synthetic conversation to the app;
- compare exact known message count, bodies, dates, senders, and order;
- stress-test large histories and explicit error behavior.

## Gate 4 — attachments

Prove photos/video/audio/files can be moved through the Shortcut boundary without silent omissions. Preserve originals where possible and hash copied files.

## Gate 5 — batch transaction

Enumerate selected conversations, import them one at a time, stage all exports locally, verify manifest counts/hashes, then expose the completed archive directory through the share sheet.

## Gate 6 — PDF

Render archival PDF from the same canonical model. PDF is an output view, never the sole stored representation.

## Gate 7 — release

- accessibility and Dynamic Type pass
- privacy manifest
- no analytics/ads/network backend
- reproducible build instructions
- App Store privacy declaration consistent with code
- external beta on non-critical devices
- App Review
- permanent free App Store listing

## Current blocker

The Mac development host has Apple command-line Swift but not Xcode. A physical iPhone running iOS 26+ is also required before the Messages import path can be marked VERIFIED.
