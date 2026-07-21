# Filza Minizip Codemagic 專案

## GitHub 根目錄結構

請保持根目錄只有以下兩個檔案和一個資料夾：

```text
codemagic.yaml
README.md
FilzaMinizip/
```

輸入 IPA 必須放在：

```text
FilzaMinizip/input/FilzaJailed.ipa
```

上傳到 GitHub 後，在 Codemagic 選擇工作流程：

```text
Build Filza Minizip Hook
```

成功後產物為：

```text
FilzaMinizip/build/FilzaJailed_MinzipHook.ipa
FilzaMinizip/build/FilzaMinizipShim.dylib
```
