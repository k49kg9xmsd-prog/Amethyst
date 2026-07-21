# Filza Minizip Hook Builder

這個專案會在 Codemagic 的 macOS 建置機上完成以下工作：

1. 從 zlib 官方原始碼編譯 iOS arm64 `FilzaMinizipShim.dylib`。
2. Shim 直接匯出 `zipOpen64`、`zipWriteInFileInZip`、`zipClose`、`unzOpen64` 等 minizip 符號。
3. 將 Shim 以弱載入方式注入 DarkSword Filza 主程式。
4. 重新打包成 IPA，供 ESign、SideStore 或其他側載簽名工具重新簽名。

這不是完整重寫 Filza 的 ZIP 介面；它是針對 DarkSword dylib 使用 `dlsym(RTLD_DEFAULT, ...)` 尋找 minizip 符號的相容性修補。

## 上傳 GitHub

1. 建立一個私人 GitHub 倉庫。
2. 把本專案全部上傳。
3. 將你原本能正常啟動、能讀取 `/var` 的 DarkSword Filza IPA 放到：

   `input/FilzaJailed.ipa`

4. 因為 `.gitignore` 預設忽略 IPA，使用 GitHub 網頁上傳時需要先移除 `.gitignore` 裡的 `input/*.ipa`，或在電腦執行：

   ```bash
   git add -f input/FilzaJailed.ipa
   git commit -m "Add private build input"
   git push
   ```

請保持倉庫為私人，避免公開散布第三方 App。

## Codemagic 編譯

1. 登入 Codemagic，連接這個 GitHub 倉庫。
2. 選擇使用倉庫內的 `codemagic.yaml`。
3. 啟動 `Build Filza Minizip Hook` workflow。
4. 編譯完成後，在 Artifacts 下載：

   `FilzaJailed_MinzipHook.ipa`

5. 使用 ESign 重新簽名。建議先改成新的 Bundle ID，和目前正常版本並存測試。

此 workflow 不需要 Apple 開發者憑證，產物會先以 ad-hoc 方式整理簽名結構；真正安裝前仍需由你的側載工具重新簽名。

## 測試順序

1. 確認 App 可以啟動。
2. 確認仍能讀取 `/var`。
3. 在 Filza 自己的 Documents 建立小資料夾與文字檔。
4. 測試建立 ZIP。
5. 再測試其他 App 容器中的小型資料夾。
6. 最後才測試大型 App 資料夾。

## 重要限制

- 若 DarkSword 的 ZIP Hook 除了缺少 minizip 符號，還存在方法簽名、路徑、權限或記憶體錯誤，這個 Shim 只能解決「符號找不到」的部分。
- WebDAV 通常依賴另一個 Helper/子程序；這個專案不會自動修復 WebDAV。
- 產物若無法安裝，先確認 ESign 已對主程式、Frameworks 與 dylib 全部重新簽名。
