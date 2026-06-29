@echo off
chcp 65001 >nul
echo ========================================
echo   Ростелеком — Запуск Go-сервера
echo ========================================
echo.

where go >nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] Go не найден! Установите Go 1.23+
    pause
    exit /b 1
)

:: Проверка и создание БД PostgreSQL (если psql доступен)
where psql >nul 2>&1
if not errorlevel 1 (
    echo [0/3] Проверка БД PostgreSQL...
    psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'rostelecom_requests'" | findstr "1" >nul 2>&1
    if errorlevel 1 (
        echo      Создание БД rostelecom_requests...
        psql -U postgres -c "CREATE DATABASE rostelecom_requests;"
        echo      БД создана!
    ) else (
        echo      БД rostelecom_requests уже существует
    )
) else (
    echo [!] psql не найден. Создайте БД rostelecom_requests вручную!
    echo     Команда: CREATE DATABASE rostelecom_requests;
    echo.
)

cd /d "%~dp0server"

echo [1/3] Загрузка зависимостей...
go mod tidy

echo [2/3] Генерация Ent...
go generate ./ent

echo [3/3] Запуск сервера...
echo.
echo ========================================
echo   API: http://localhost:8080
echo   Health: http://localhost:8080/health
echo ========================================
echo.
echo Тестовые пользователи (пароль: password123):
echo   admin       — Администратор
echo   dispatcher1 — Диспетчер
echo   technik1    — Выездной техник
echo   technik2    — Выездной техник
echo   supervisor1 — Руководитель
echo.
echo Ent ORM автоматически создаст таблицы при первом запуске.
echo Сервер слушает все интерфейсы (0.0.0.0:8080).
echo.
go run ./cmd/server/
