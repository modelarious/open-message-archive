# A free, local iMessage archive: clean-room feasibility

## Problem

Preserving a loved one's message history should not depend on a recurring subscription. The target product is deliberately narrow: preserve conversations faithfully, on the phone, into portable files.

## Constraint that matters

An ordinary third-party iOS app cannot simply open Apple's private Messages database. Earlier investigation therefore treated a native exporter as questionable.

iOS 26 changed the available system surface: Apple added **Find Message** and **Find Conversation** actions to Shortcuts.

## The useful discovery

TextPort's public support documentation explains its boundary directly: the application installs a Shortcut because the app itself cannot read Messages; Apple's Shortcut reads the selected conversation with user permission and hands the result back to the app.

That public behavior is sufficient to establish an independent clean-room architecture. The project does not need TextPort's binary, source code, assets, Shortcut implementation, branding or private implementation details.

## Architecture selected

The project uses:

1. an open-source, inspectable Shortcut as the Messages reader;
2. a small Swift app as the local archive, validation and rendering engine;
3. a canonical JSON representation;
4. TXT, CSV and HTML renderers first;
5. PDF as another view over the same archive;
6. system sharing only after a complete local export exists.

There is no backend, account, subscription, analytics service or required cloud storage.

## What the first implementation actually proved

The repository contains a Codable archive model and deterministic renderers for JSON, text, CSV and self-contained HTML.

The first generated source had a malformed quote-escaping implementation. Clean GitHub Actions caught it. The escaping code was corrected, additional CSV/HTML edge-case tests were added, and the portable core then passed CI.

A second CI gate was added specifically to avoid treating plausible-looking SwiftUI as an implementation. GitHub's macOS 26 runner generated the Xcode project and compiled the iOS 26 application under Xcode 26.6. Swift 6/AppIntents compiler errors were fixed until both the portable core and the iOS application target passed in the same clean run.

So two claims are now evidence-backed:

- **VERIFIED:** the portable archive/rendering core passes its tests.
- **COMPILE-VERIFIED:** the iOS SwiftUI/AppIntent application is valid under Xcode 26.

## What remains unverified

The critical Messages bridge has not run on a physical iPhone.

Apple documents the Messages actions, and a shipping product publicly documents the same system architecture, but Simulator cannot prove real Messages-history behavior. We will not claim completeness until a separate non-critical iPhone with synthetic conversations proves exact message counts, ordering, sender identity and failure behavior.

Attachment behavior is also a separate gate. Public product documentation highlights a real iOS constraint: old attachments that exist only in iCloud are not readable by the Shortcut until they are downloaded to the device. Our app must preserve that distinction instead of silently omitting media.

## Local-first failure model

Batch exports will be staged to a local transaction directory and validated before the system share sheet is shown. A full Google Drive, Dropbox account or other File Provider therefore cannot leave the only archive half-created.

## Next evidence

Finish the reproducible clean-room companion Shortcut source, then run it only on a non-critical physical iPhone running iOS 26+ with synthetic messages. The bereaved family's phone is not an acceptable first test device.
