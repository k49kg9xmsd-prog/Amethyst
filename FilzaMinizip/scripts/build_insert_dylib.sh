#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEPS="$ROOT/.deps"
TOOLS="$ROOT/.tools"
REPO="$DEPS/insert_dylib"

mkdir -p "$DEPS" "$TOOLS"

# Always start from a clean checkout so an interrupted Codemagic build cannot
# leave a half-cloned dependency behind.
rm -rf "$REPO"
git clone --depth 1 https://github.com/tyilo/insert_dylib.git "$REPO"

# The current upstream project is a single C source file. Older versions of
# this script expected obsolete C++ files such as MachOFile.cpp, which no
# longer exist in the repository.
SOURCE="$REPO/insert_dylib/main.c"
if [[ ! -f "$SOURCE" ]]; then
  SOURCE="$(find "$REPO" -type f -name 'main.c' | head -n 1)"
fi

if [[ -z "${SOURCE:-}" || ! -f "$SOURCE" ]]; then
  echo "找不到 insert_dylib 的 main.c" >&2
  echo "實際下載內容：" >&2
  find "$REPO" -maxdepth 3 -type f -print >&2
  exit 1
fi

echo "使用來源檔：$SOURCE"
xcrun clang -std=gnu11 -O2 "$SOURCE" -o "$TOOLS/insert_dylib"
chmod 755 "$TOOLS/insert_dylib"

# Fail here instead of waiting until the IPA patch step.
"$TOOLS/insert_dylib" 2>&1 | head -n 3 || true
test -x "$TOOLS/insert_dylib"
echo "insert_dylib 編譯完成：$TOOLS/insert_dylib"
