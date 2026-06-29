# Ростелеком — Управление заявками абонентов

Мобильное приложение для управления заявками выездных техников Ростелекома.  
Техники получают заявки на подключение/ремонт интернета/ТВ/телефонии, берут их в работу и закрывают с отчётом.

## Стек технологий

| Компонент | Технология |
|-----------|------------|
| Мобильное приложение | Flutter (Dart) |
| Серверная часть (API) | Go (Gin + Ent ORM) |
| База данных | PostgreSQL 16 |

## Структура проекта

```
rostelecom_app/
├── server/          — Go REST API (Gin + Ent)
├── mobile_app/      — Flutter мобильное приложение
├── database/        — SQL-схема PostgreSQL
├── start_server.bat — запуск сервера
├── start_app.bat    — запуск Flutter-приложения
└── docker-compose.yml (опционально)
```

## Требования

- **Go 1.23+** — [golang.org](https://golang.org/dl/)
- **PostgreSQL 16** — [postgresql.org](https://www.postgresql.org/download/)
- **Flutter 3.11+** — [flutter.dev](https://flutter.dev/docs/get-started/install)
- **Android Studio / эмулятор** — для запуска Flutter-приложения

## Локальный запуск (пошагово)

### Шаг 1. Создать БД в PostgreSQL

Откройте pgAdmin или psql и выполните:

```sql
CREATE DATABASE rostelecom_requests;
```

> Если у вас пароль PostgreSQL **не** `postgres`, отредактируйте файл `server/.env`:
> ```
> DB_PASSWORD=ваш_пароль
> ```

### Шаг 2. Запустить Go-сервер

```bash
start_server.bat
```

Или вручную:
```bash
cd server
go mod tidy
go generate ./ent
go run ./cmd/server/
```

Сервер запустится на `http://localhost:8080`.  
**Ent ORM автоматически создаст все таблицы** и заполнит их тестовыми данными.

Проверьте: откройте в браузере `http://localhost:8080/health` — должен вернуть `{"status":"ok"}`.

### Шаг 3. Запустить Flutter-приложение

```bash
start_app.bat
```

Или вручную:
```bash
cd mobile_app
flutter pub get
flutter run
```

#### Варианты запуска Flutter:
- **Chrome (Web):** `flutter run -d chrome` — подключается к `localhost:8080`
- **Android эмулятор:** `flutter run` — подключается к `10.0.2.2:8080` (автоматически маппится на localhost хоста)
- **Windows desktop:** `flutter run -d windows` — подключается к `localhost:8080`

> **Важно:** сервер должен быть запущен ДО запуска приложения!

## Тестовые пользователи

Пароль для всех: `password123`

| Логин | Роль | Что может |
|-------|------|-----------|
| admin | Администратор | Всё + управление пользователями |
| dispatcher1 | Диспетчер | Создаёт и распределяет заявки |
| technik1 | Выездной техник | Видит свои заявки, меняет статус |
| technik2 | Выездной техник | Видит свои заявки, меняет статус |
| supervisor1 | Руководитель | Мониторинг, создание заявок |

## Конфигурация

Файл `server/.env`:
```env
DB_HOST=localhost      # Адрес PostgreSQL
DB_PORT=5432           # Порт PostgreSQL
DB_USER=postgres       # Пользователь PostgreSQL
DB_PASSWORD=postgres   # Пароль PostgreSQL
DB_NAME=rostelecom_requests  # Имя БД
SERVER_PORT=8080       # Порт API сервера
```

Файл `mobile_app/lib/config/environment.dart`:
- Автоматически определяет адрес API в зависимости от платформы
- Для физического устройства Android — замените IP на адрес вашего ПК в локальной сети

## API Endpoints

### Публичные
- `POST /api/v1/auth/login` — авторизация
- `POST /api/v1/auth/refresh` — обновление токена
- `GET /api/v1/references/*` — справочники

### Авторизованные
- `GET /api/v1/requests` — список заявок
- `GET /api/v1/requests/:id` — детали заявки
- `PUT /api/v1/requests/:id` — обновление заявки
- `GET /api/v1/requests/:id/history` — история изменений
- `GET /api/v1/notifications` — уведомления
- `GET /api/v1/profile` — профиль пользователя

### Диспетчер / Руководитель / Админ
- `POST /api/v1/requests` — создание заявки
- `DELETE /api/v1/requests/:id` — удаление заявки
- `GET /api/v1/export/csv` — экспорт в CSV

### Только админ
- `GET/POST/PUT/DELETE /api/v1/admin/users` — управление пользователями

## База данных (10 таблиц, 3НФ)

1. `roles` — справочник ролей
2. `service_types` — типы услуг (Интернет, ТВ, Телефония, Видеонаблюдение)
3. `request_statuses` — статусы заявок
4. `request_categories` — категории (Подключение, Ремонт, Консультация, Модернизация)
5. `users` — пользователи системы
6. `addresses` — адреса клиентов
7. `requests` — заявки абонентов
8. `request_history` — журнал изменений
9. `notifications` — уведомления
10. `refresh_tokens` — токены авторизации
