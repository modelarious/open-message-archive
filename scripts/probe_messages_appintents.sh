#!/bin/bash
set -euo pipefail

echo "== Xcode =="
xcodebuild -version

echo "== Available runtimes =="
xcrun simctl list runtimes

echo "== Locate Messages.app in installed simulator runtimes =="
SEARCH_ROOTS=(
  "/Library/Developer/CoreSimulator/Volumes"
  "/Library/Developer/CoreSimulator/Profiles/Runtimes"
  "$(xcode-select -p)/Platforms/iPhoneSimulator.platform/Library/Developer/CoreSimulator/Profiles/Runtimes"
)

FOUND=()
for root in "${SEARCH_ROOTS[@]}"; do
  [[ -d "$root" ]] || continue
  while IFS= read -r file; do
    FOUND+=("$file")
  done < <(find "$root" -type f -path '*/Messages.app/*/Metadata.appintents/extract.actionsdata' -print 2>/dev/null || true)
done

# De-duplicate paths.
mapfile -t FILES < <(printf '%s\n' "${FOUND[@]}" | awk 'NF && !seen[$0]++' | sort)

echo "Metadata files: ${#FILES[@]}"
if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "No Messages AppIntents metadata found in installed simulator runtimes." >&2
  echo "Runtime roots inspected:" >&2
  printf '  %s\n' "${SEARCH_ROOTS[@]}" >&2
  exit 2
fi

for file in "${FILES[@]}"; do
  echo "===== $file ====="
  python3 - "$file" <<'PY'
import json, pathlib, sys
p = pathlib.Path(sys.argv[1])
obj = json.loads(p.read_text())
serialized = json.dumps(obj, sort_keys=True)
interesting = any(term in serialized for term in (
    "MessageEntity", "ConversationEntity", "Find Message", "Find Conversation",
    "conversation", "sender", "body", "attachments"
))
summary = {
    "path": str(p),
    "interesting": interesting,
    "entities": sorted(obj.get("entities", {}).keys()),
    "queries": sorted(obj.get("queries", {}).keys()),
    "actions": sorted(obj.get("actions", {}).keys()),
}
print(json.dumps(summary, indent=2, sort_keys=True))
if interesting:
    print("--- INTERESTING METADATA ---")
    print(json.dumps(obj, indent=2, sort_keys=True))
PY
done
