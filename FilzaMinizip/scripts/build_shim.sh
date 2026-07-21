#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPS="$ROOT/.deps"
OUT="$ROOT/build"
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
CLANG="$(xcrun --sdk iphoneos --find clang)"
MIN_IOS="${MIN_IOS:-15.0}"

mkdir -p "$DEPS" "$OUT"

if [[ ! -d "$DEPS/zlib" ]]; then
  git clone --depth 1 --branch v1.3.1 https://github.com/madler/zlib.git "$DEPS/zlib"
fi

MINIZIP="$DEPS/zlib/contrib/minizip"

"$CLANG" \
  -arch arm64 \
  -isysroot "$SDK" \
  -miphoneos-version-min="$MIN_IOS" \
  -dynamiclib \
  -fvisibility=default \
  -Wl,-install_name,@executable_path/Frameworks/FilzaMinizipShim.dylib \
  -Wl,-dead_strip \
  -I"$DEPS/zlib" \
  -I"$MINIZIP" \
  "$ROOT/Sources/FilzaMinizipShim/shim.c" \
  "$MINIZIP/ioapi.c" \
  "$MINIZIP/zip.c" \
  "$MINIZIP/unzip.c" \
  -lz \
  -o "$OUT/FilzaMinizipShim.dylib"

file "$OUT/FilzaMinizipShim.dylib"
nm -gU "$OUT/FilzaMinizipShim.dylib" | grep -E '_(zipOpen64|zipWriteInFileInZip|zipClose|unzOpen64)$' || {
  echo "Required minizip exports were not found" >&2
  exit 1
}
