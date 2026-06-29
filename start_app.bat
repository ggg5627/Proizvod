@echo off
chcp 65001 >nul
echo ========================================
echo   Ростелеком — Flutter App
echo ========================================

where flutter >nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] Flutter не найден!
    pause
    exit /b 1
)

cd /d "%~dp0mobile_app"

echo [1/2] Установка зависимостей...
call flutter pub get

echo [2/2] Запуск приложения...
echo Убедитесь, что сервер запущен!
call flutter run
