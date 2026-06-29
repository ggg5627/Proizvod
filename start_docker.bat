@echo off
chcp 65001 >nul
echo ========================================
echo   Ростелеком — Docker Compose
echo ========================================
echo.
echo Запуск PostgreSQL + Go-сервер...
docker compose up --build -d
echo.
echo PostgreSQL: localhost:5432
echo API:        http://localhost:8080
echo.
pause
