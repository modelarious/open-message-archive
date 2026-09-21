# Companion Shortcut contract

Status: **SPECIFIED, NOT YET PHYSICAL-DEVICE VERIFIED**

The first physical-device milestone is to construct and inspect a Shortcut using only Apple actions.

## Required Apple actions

iOS 26 or newer:

- Messages: Find Conversation
- Messages: Find Message
- ordinary Shortcuts list/dictionary/date/file actions
- the app's **Import Conversation Archive** App Intent

## V1 user flow

1. Run **Archive a Messages Conversation**.
2. Choose one conversation.
3. Choose a start date and end date (or all available history).
4. Find messages belonging to that conversation in ascending date order.
5. For each message, extract the public Shortcuts properties needed by schema v1:
   - body
   - sender
   - date
   - conversation
   - attachment descriptors when available
6. Build a schema-v1 JSON object.
7. Create a temporary JSON file.
8. Pass that file to **Import Conversation Archive**.
9. The app validates and stores the archive locally.

## Schema v1

```json
{
  "schemaVersion": 1,
  "conversation": {
    "id": null,
    "displayName": "Example",
    "participants": ["Example", "Me"]
  },
  "exportedAt": "2026-09-21T20:00:00Z",
  "messages": [
    {
      "id": null,
      "date": "2026-09-21T19:00:00Z",
      "sender": "Example",
      "direction": "incoming",
      "body": "Hello",
      "attachments": []
    }
  ]
}
```

## Acceptance gate

Do not publish the Shortcut as production-ready until a physical iPhone running iOS 26+ proves:

- a one-to-one thread imports completely for a known date interval;
- chronological order is stable;
- outgoing/incoming identity is correct;
- Unicode and multiline bodies survive;
- a long thread does not silently truncate;
- failures are explicit rather than partial-success;
- no message mutation occurs.

Attachments and group chats get separate gates.
