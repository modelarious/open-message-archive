# Architecture

## Non-negotiable invariants

1. Conversation contents never require a hosted server.
2. The primary Messages import path uses Apple-visible user-authorized Shortcuts actions, not private Messages APIs.
3. The canonical archive is created locally before any share/upload step begins.
4. Cloud destinations are optional system share/File Provider destinations after export, never required storage during generation.
5. The original Messages conversation is read-only.
6. The app remains useful without an account, subscription, analytics SDK, advertising SDK, or network connection.

## Data flow

```text
Apple Messages
    |
    | iOS 26 Shortcuts: Find Conversation / Find Message
    v
Open-source companion Shortcut
    |
    | structured JSON (+ attachment bundle in a later milestone)
    v
Open Message Archive
    |
    +--> canonical local JSON
    +--> TXT
    +--> CSV
    +--> self-contained HTML
    +--> PDF (planned)
    |
    v
System share sheet / Files provider chosen by the user
```

## Why a Shortcut boundary exists

Ordinary iOS applications do not have a public API to read arbitrary Apple Messages history. iOS 26 added Messages **Find Message** and **Find Conversation** actions to Shortcuts. The Shortcut is therefore the privileged, inspectable reader. The app owns validation, archival representation, rendering, and export.

## Canonical archive

The JSON model is intentionally boring: conversation metadata plus chronologically ordered messages and attachment descriptors. Export formats are derived views. This keeps preservation independent from any particular renderer.

## Batch export

Batch mode will stage every selected conversation into an app-local transaction directory. Only after all requested conversations and export files complete successfully will the app expose the directory for sharing/moving. That prevents a full Dropbox/Drive account or provider error from producing an ambiguous half-archive.

## Attachments

Attachments are represented in the schema now, but the iOS Shortcut attachment-transfer path is a separate acceptance gate. We will not claim attachment completeness until verified on a physical iPhone.
