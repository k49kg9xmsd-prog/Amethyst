#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INPUT_IPA="${1:-$ROOT/input/FilzaJailed.ipa}"
OUTPUT_IPA="${2:-$ROOT/build/FilzaJailed_MinzipHook.ipa}"
WORK="$ROOT/.work"
SHIM="$ROOT/build/FilzaMinizipShim.dylib"
INSERT="$ROOT/.tools/insert_dylib"

[[ -f "$INPUT_IPA" ]] || { echo "Missing input IPA: $INPUT_IPA" >&2; exit 1; }
[[ -f "$SHIM" ]] || { echo "Missing shim dylib" >&2; exit 1; }
[[ -x "$INSERT" ]] || { echo "Missing insert_dylib tool" >&2; exit 1; }

rm -rf "$WORK"
mkdir -p "$WORK" "$(dirname "$OUTPUT_IPA")"
ditto -x -k "$INPUT_IPA" "$WORK"

APP="$(find "$WORK/Payload" -maxdepth 1 -type d -name '*.app' | head -1)"
[[ -n "$APP" ]] || { echo "No .app found in IPA" >&2; exit 1; }

EXECUTABLE="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Info.plist")"
MAIN="$APP/$EXECUTABLE"
[[ -f "$MAIN" ]] || { echo "Main executable not found: $MAIN" >&2; exit 1; }

mkdir -p "$APP/Frameworks"
cp "$SHIM" "$APP/Frameworks/FilzaMinizipShim.dylib"
chmod 755 "$APP/Frameworks/FilzaMinizipShim.dylib"

# Add a weak load command. Weak loading prevents launch failure if the file is
# accidentally removed, while still making the exported symbols visible to dlsym.
"$INSERT" --inplace --strip-codesig \
  --weak @executable_path/Frameworks/FilzaMinizipShim.dylib "$MAIN"

# Remove stale signatures/provisioning. The result is intended to be signed by
# ESign/SideStore after download.
find "$APP" -type d -name _CodeSignature -prune -exec rm -rf {} +
find "$APP" -name 'CodeResources' -delete || true
rm -f "$APP/embedded.mobileprovision"

# Ad-hoc sign nested Mach-O files to keep the bundle structurally coherent.
# A sideloading signer will replace these signatures later.
while IFS= read -r -d '' f; do
  if file "$f" | grep -q 'Mach-O'; then
    codesign --force --sign - --timestamp=none "$f" >/dev/null 2>&1 || true
  fi
done < <(find "$APP" -type f -print0)
codesign --force --deep --sign - --timestamp=none "$APP" >/dev/null 2>&1 || true

rm -f "$OUTPUT_IPA"
(
  cd "$WORK"
  ditto -c -k --sequesterRsrc --keepParent Payload "$OUTPUT_IPA"
)

echo "Created: $OUTPUT_IPA"
