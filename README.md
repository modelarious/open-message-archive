# Open Message Archive

A free, open-source, local-first conversation archiver for iPhone.

## Why

People should not need a subscription to preserve conversations that matter to them. This project is intended to make iMessage/SMS preservation available without a backend, account, analytics pipeline, or recurring fee.

## Architecture

On iOS 26+, Apple Shortcuts provides **Find Message** and **Find Conversation** actions for Messages. A visible, user-auditable Shortcut gathers the conversation with the user's permission and passes a structured archive to this app. The app validates it, stores it locally, and exports portable formats.

**No private Messages API. No server. No cloud dependency. No screen scraping for the primary Messages path.**

## Formats

Initial core support:

- plain text
- CSV
- self-contained HTML
- canonical JSON archive

PDF is planned as a renderer over the same canonical archive.

## Privacy invariant

Message content is processed locally. The app does not require an account or hosted service. Exports are fully created on-device before the user chooses a destination through the system share sheet / Files providers.

## Status

Early implementation. The export core is testable now. The iOS 26 Shortcut-to-app bridge requires Xcode 26 and a physical iPhone before it can be declared verified.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), [docs/CLEAN_ROOM.md](docs/CLEAN_ROOM.md), and [docs/PLAN.md](docs/PLAN.md).

## License

MIT.
