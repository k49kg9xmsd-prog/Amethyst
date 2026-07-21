# Filza Minizip Hook Codemagic 專案

GitHub 根目錄請保持只有：

```text
README.md
codemagic.yaml
FilzaMinizip/
```

目前版本會：

- 保留原本 Filza 名稱與圖示。
- 保留 DarkSword 的 `/var` 存取能力。
- 內嵌 Minizip Shim，修復已實測成功的 ZIP 建立功能。
- 同時匯出 unzip 相關函式，但解壓功能仍需實機測試。

Codemagic 成功後下載：

```text
FilzaMinizip/build/FilzaJailed_MinzipHook.ipa
```

再使用輕鬆簽簽署全部動態庫後安裝。
