@echo off
chcp 65001 > nul
setlocal

rem ===== Android Auto DHU をワンクリックで起動 =====
rem 前提：スマホを USB で接続し、Android Auto の「ヘッドユニット サーバーを起動」を実行済み

set "SDK=%LOCALAPPDATA%\Android\Sdk"
set "DHU_DIR=%SDK%\extras\google\auto"

rem adb は PATH にあればそれを、なければ SDK 内のものを使う
where adb > nul 2>&1
if %errorlevel%==0 (
    set "ADB=adb"
) else (
    set "ADB=%SDK%\platform-tools\adb.exe"
)

if not exist "%DHU_DIR%\desktop-head-unit.exe" (
    echo [エラー] DHU が見つかりません: %DHU_DIR%
    echo SDK Manager で「Android Auto Desktop Head Unit Emulator」を入れてください。
    pause
    exit /b 1
)

rem 端末の接続確認（1台だけ接続している前提）
"%ADB%" get-state > nul 2>&1
if not %errorlevel%==0 (
    echo [エラー] スマホが認識されていません。USB 接続と USB デバッグの許可を確認してください。
    pause
    exit /b 1
)

rem ヘッドユニットサーバーへのポート転送
"%ADB%" forward tcp:5277 tcp:5277
if not %errorlevel%==0 (
    echo [エラー] ポート転送に失敗しました。
    pause
    exit /b 1
)

echo DHU を起動します。「Waiting for phone」のままなら、スマホでヘッドユニット サーバーを起動し直してください。
cd /d "%DHU_DIR%"
desktop-head-unit.exe %*

endlocal
