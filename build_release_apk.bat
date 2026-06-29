@echo off
chcp 65001 >nul
echo ========================================
echo   Ростелеком — Сборка APK
echo ========================================

cd /d "%~dp0mobile_app"
call flutter clean
call flutter pub get
call flutter build apk --release

if exist "build\app\outputs\flutter-apk\app-release.apk" (
    copy "build\app\outputs\flutter-apk\app-release.apk" "..\..\rostelecom-release.apk"
    echo.
    echo APK: rostelecom-release.apk
) else (
    echo [ОШИБКА] APK не найден!
)
pause
