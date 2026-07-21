#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPS="$ROOT/.deps"
TOOLS="$ROOT/.tools"
mkdir -p "$DEPS" "$TOOLS"

if [[ ! -d "$DEPS/insert_dylib" ]]; then
  git clone --depth 1 https://github.com/Tyilo/insert_dylib.git "$DEPS/insert_dylib"
fi

xcrun clang++ -std=c++11 -O2 \
  "$DEPS/insert_dylib/insert_dylib/main.cpp" \
  "$DEPS/insert_dylib/insert_dylib/ThinFatFile.cpp" \
  "$DEPS/insert_dylib/insert_dylib/TruncatedFile.cpp" \
  "$DEPS/insert_dylib/insert_dylib/FatFile.cpp" \
  "$DEPS/insert_dylib/insert_dylib/MachOFile.cpp" \
  -o "$TOOLS/insert_dylib"
