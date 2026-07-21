#!/bin/bash
set -euo pipefail

APP="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ICON="$ROOT/NekzaIcon.jpg"
PLIST="$APP/Info.plist"

[[ -d "$APP" ]] || { echo "找不到 App：$APP" >&2; exit 1; }
[[ -f "$ICON" ]] || { echo "找不到圖示：$ICON" >&2; exit 1; }

set_plist_string() {
  local plist="$1" key="$2" value="$3"
  /usr/libexec/PlistBuddy -c "Set :$key $value" "$plist" 2>/dev/null || \
  /usr/libexec/PlistBuddy -c "Add :$key string $value" "$plist"
}

set_plist_string "$PLIST" CFBundleDisplayName Nekza
set_plist_string "$PLIST" CFBundleName Nekza

# 同步修改內建擴充套件的顯示名稱，避免分享頁仍顯示舊名稱。
while IFS= read -r -d '' extplist; do
  set_plist_string "$extplist" CFBundleDisplayName Nekza
  set_plist_string "$extplist" CFBundleName Nekza
 done < <(find "$APP/PlugIns" -name Info.plist -print0 2>/dev/null || true)

# Filza 4.0.2 使用傳統 PNG 圖示檔；逐一依檔名尺寸覆蓋。
render_icon() {
  local filename="$1" size="$2"
  local target="$APP/$filename"
  [[ -f "$target" ]] || return 0
  sips -s format png -z "$size" "$size" "$ICON" --out "$target" >/dev/null
}

render_icon AppIcon29x29.png 29
render_icon AppIcon29x29@2x.png 58
render_icon AppIcon29x29@3x.png 87
render_icon AppIcon40x40@2x.png 80
render_icon AppIcon40x40@3x.png 120
render_icon AppIcon60x60@2x.png 120
render_icon AppIcon60x60@3x.png 180
render_icon AppIcon29x29~ipad.png 29
render_icon AppIcon29x29@2x~ipad.png 58
render_icon AppIcon40x40~ipad.png 40
render_icon AppIcon40x40@2x~ipad.png 80
render_icon AppIcon76x76~ipad.png 76
render_icon AppIcon76x76@2x~ipad.png 152
render_icon AppIcon83.5x83.5@2x~ipad.png 167

# 擴充套件圖示也一起換掉。
render_icon ExtensionIcon60x60@2x.png 120
render_icon ExtensionIcon76x76@2x~ipad.png 152

echo "已套用 Nekza 名稱與應用圖示。"
