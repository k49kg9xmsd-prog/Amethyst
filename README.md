# Nekza Codemagic 專案

GitHub 根目錄請保持只有：

```text
README.md
codemagic.yaml
FilzaMinizip/
```

目前版本會：

- 保留 DarkSword 的 `/var` 存取能力。
- 內嵌 Minizip Shim，修復已實測成功的 ZIP 建立功能。
- 同時匯出 unzip 相關函式，供原本的解壓 Hook 使用。
- 將應用名稱改為 `Nekza`。
- 將主程式與擴充套件圖示換成專案內的 `NekzaIcon.jpg`。

Codemagic 成功後下載：

```text
FilzaMinizip/build/Nekza.ipa
```

再使用輕鬆簽簽署全部動態庫後安裝。
