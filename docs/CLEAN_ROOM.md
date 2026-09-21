# Clean-room interoperability policy

This project reproduces a useful capability, not another application's implementation.

## Sources we may use

- Apple's public documentation and SDKs.
- Publicly visible App Store descriptions, support guides, screenshots, and user-visible behavior.
- Our own synthetic test conversations and measurements.
- Independently written open-source libraries with compatible licenses.

## Things we do not copy

- Proprietary application binaries or extracted source.
- Private assets, icons, branding, UI artwork, or text.
- Proprietary network protocols obtained by bypassing access controls.
- Decompiled implementations.
- Subscription/paywall logic.

## Current independently established mechanism

TextPort's public support guide states that its iOS 26 Messages import uses an Apple Shortcut because apps cannot read Messages on their own; the Shortcut reads the selected chat and passes it to the app. Apple independently documents the iOS 26 **Find Message** and **Find Conversation** Shortcuts actions.

That public architecture is sufficient to design an independent implementation.

## Product differentiation

Open Message Archive is deliberately local-first, free, open source, serverless, and archive-oriented. It uses its own data model, export design, UI, branding, and code.
