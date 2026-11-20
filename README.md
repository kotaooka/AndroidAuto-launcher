# AndroidAuto-launcher

Android Auto の **Desktop Head Unit（DHU）** を Windows でワンクリック起動するバッチファイルです。
`adb forward` と DHU 本体の起動を `dhu.bat` 1 本にまとめています。

## 動作環境

- Windows 11 / PowerShell またはエクスプローラーからのダブルクリック
- Android SDK（既定パス `%LOCALAPPDATA%\Android\Sdk`）
  - SDK Platform-Tools（`adb`）
  - Android Auto Desktop Head Unit Emulator（SDK Manager の「SDK Tools」タブで導入）
- Android Auto が入った Android 端末と USB ケーブル

## 事前準備（初回のみ）

1. **端末で USB デバッグを有効化**
   設定 → デバイス情報 → ビルド番号を 7 回タップ → 開発者向けオプション → USB デバッグを ON。
2. **Android Auto の開発者モードを有効化**
   Android Auto の設定画面で「バージョン」を 10 回タップ → 開発者向け設定を有効化。
3. **SDK Manager で DHU を導入**
   Android Studio → SDK Manager → SDK Tools → 「Android Auto Desktop Head Unit Emulator」にチェック。
   `%LOCALAPPDATA%\Android\Sdk\extras\google\auto\desktop-head-unit.exe` が存在すれば OK。

## 使い方

1. 端末を PC に USB 接続し、USB デバッグを許可する。
2. Android Auto の右上メニュー（︙）→ **「ヘッドユニット サーバーを起動」** を実行する。
3. `dhu.bat` をダブルクリック、または PowerShell から実行する。

```powershell
.\dhu.bat
```

引数はそのまま `desktop-head-unit.exe` に渡されます（`%*`）。DHU のオプションは公式ドキュメントを参照してください。

```powershell
.\dhu.bat --help
```

## 処理の流れ

| 手順 | 内容 | 失敗時 |
|---|---|---|
| 1 | `adb` を探す（PATH 優先、無ければ SDK 内 `platform-tools\adb.exe`） | — |
| 2 | `desktop-head-unit.exe` の存在確認 | エラー表示して終了 |
| 3 | `adb get-state` で端末接続確認 | エラー表示して終了 |
| 4 | `adb forward tcp:5277 tcp:5277`（ヘッドユニットサーバーへの転送） | エラー表示して終了 |
| 5 | DHU のディレクトリへ移動して起動 | — |

## トラブルシューティング

| 症状 | 原因と対処 |
|---|---|
| `[エラー] DHU が見つかりません` | DHU 未導入、または SDK が既定パス以外。`dhu.bat` 8 行目の `SDK` を実際のパスに書き換える。 |
| `[エラー] スマホが認識されていません` | USB デバッグ未許可、ケーブルが充電専用、ドライバ未導入。`adb devices` で `device` と表示されるか確認。 |
| DHU が「Waiting for phone」のまま | 端末側でヘッドユニットサーバーが止まっている。Android Auto のメニューから起動し直す。 |
| 端末を 2 台以上つなぐと失敗する | `adb get-state` / `adb forward` は複数端末だと対象を特定できず失敗する。1 台だけ接続する。 |
| 文字化けする | `dhu.bat` は UTF-8（CRLF）で保存し、`chcp 65001` でコードページを切り替えている。編集時は UTF-8 のまま保存する（Shift_JIS で保存すると日本語メッセージが化ける）。 |

## 参考

- Android Developers: Test Android apps for cars using the Desktop Head Unit
  https://developer.android.com/training/cars/testing/dhu

## ファイル構成

```
AndroidAuto-launcher/
├── dhu.bat     起動用バッチ
└── README.md
```
