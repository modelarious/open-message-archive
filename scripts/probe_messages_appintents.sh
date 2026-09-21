#!/bin/bash
set -euo pipefail

echo "== Xcode =="
xcodebuild -version

echo "== Available runtimes =="
xcrun simctl list runtimes

echo "== Available iOS simulator devices =="
xcrun simctl list devices available

UDID="$(
  xcrun simctl list devices available -j |
  python3 -c '
import json, sys
data=json.load(sys.stdin)
for runtime, devices in data["devices"].items():
    if "iOS" not in runtime:
        continue
    for device in devices:
        if device.get("isAvailable"):
            print(device["udid"])
            raise SystemExit
raise SystemExit("No available iOS simulator device")
'
)"

echo "Using simulator: $UDID"
xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b

APP_CONTAINER="$(xcrun simctl get_app_container "$UDID" com.apple.MobileSMS app)"
echo "Messages app container: $APP_CONTAINER"

mapfile -t FILES < <(find "$APP_CONTAINER" -type f -path '*/Metadata.appintents/extract.actionsdata' -print | sort)
echo "Metadata files: ${#FILES[@]}"

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "No AppIntents metadata found in simulator Messages.app" >&2
  exit 2
fi

OUT="$RUNNER_TEMP/messages-appintents-metadata.jsonl"
: > "$OUT"
for file in "${FILES[@]}"; do
  echo "===== $file ====="
  python3 - "$file" <<'PY'
import json, pathlib, sys
p=pathlib.Path(sys.argv[1])
obj=json.loads(p.read_text())
serialized=json.dumps(obj, sort_keys=True)
interesting = any(term in serialized for term in (
    "MessageEntity", "ConversationEntity", "Find Message", "Find Conversation",
    "conversation", "sender", "body", "attachments"
))
print(json.dumps({
    "path": str(p),
    "interesting": interesting,
    "entities": sorted(obj.get("entities", {}).keys()),
    "queries": sorted(obj.get("queries", {}).keys()),
    "actions": sorted(obj.get("actions", {}).keys()),
}))
if interesting:
    print(json.dumps(obj, sort_keys=True))
PY
  python3 - "$file" >> "$OUT" <<'PY'
import json, pathlib, sys
p=pathlib.Path(sys.argv[1])
obj=json.loads(p.read_text())
print(json.dumps({"path": str(p), "metadata": obj}, sort_keys=True))
PY
done

echo "== Message/Conversation references =="
grep -E 'MessageEntity|ConversationEntity|conversation|sender|body|attachments' "$OUT" || true
