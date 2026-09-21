# A free, local iMessage archive: clean-room feasibility

## Problem

Preserving a loved one's message history should not depend on a recurring subscription. The target product is deliberately narrow: preserve conversations faithfully, on the phone, into portable files.

## Constraint that matters

An ordinary third-party iOS app cannot simply open Apple's private Messages database. Earlier investigation therefore treated a native exporter as questionable.

iOS 26 changed the available system surface: Apple added **Find Message** and **Find Conversation** actions to Shortcuts.

## The useful discovery

A current commercial product's public support documentation explains its own boundary: the application installs a Shortcut because the app itself cannot read Messages; Apple's Shortcut reads the selected conversation with user permission and hands the result back to the app.

That is enough public information to establish an independent design. We do not need the commercial application's binary, source code, assets, or private implementation.

## Architecture selected

The project uses:

1. an open-source, inspectable Shortcut as the Messages reader;
2. a small Swift app as the local archive, validation, and rendering engine;
3. a canonical JSON representation;
4. TXT, CSV and HTML renderers first;
5. system sharing only after a complete local export exists.

There is no backend.

## Work completed in the first pass

The repository contains a Codable archive model and deterministic renderers for JSON, text, CSV and self-contained HTML, plus unit tests. It also contains an iOS shell and an App Intent designed to accept a JSON file from Shortcuts.

## What is not yet proved

The critical bridge has not yet run on a physical iPhone. The development Mac currently lacks Xcode, and Simulator cannot establish real Messages-history behavior. Attachment fidelity, long-thread truncation behavior, group chats, and batch exports remain explicit gates rather than assumptions.

## Next evidence

Install Xcode 26, compile the shell, and use a non-critical iOS 26+ test phone populated with synthetic conversations. Only after exact message-count and content comparisons pass should the Shortcut be distributed publicly.
