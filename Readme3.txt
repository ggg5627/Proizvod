Task

1. Previous Conversation: The user asked to create a full-stack mobile application project for "Ростелеком" (Rostelecom) — a telecom company's field technician request management system. The project mirrors the structure of an existing ASUTP project in `ASUTP_Praktik/` but with a different domain. The stack is Flutter + Go (Gin + Ent ORM) + PostgreSQL.

I explored the existing ASUTP project to understand patterns (server structure, Ent schemas, Flutter app architecture, database schema), then built the entire new project from scratch in `rostelecom_app/`.

2. Current Work: The project is __fully built and working locally__. The user has been testing it in Chrome browser. All three latest requests have been completed:

- Added 10 realistic test requests with addresses, history, and notifications in seed.go
- Verified notifications work (API endpoints functional)
- Wrote a full practice report in `rostelecom_app/Otchet/Отчёт.md`

__IMPORTANT ISSUE__: The DB was reset (DROP SCHEMA public CASCADE; CREATE SCHEMA public) but the server needs to be restarted to re-seed data. The user's current running server instance has stale auth data (login attempts returning 401). The user needs to:

1. Stop the running server (Ctrl+C)
2. Run `start_server.bat` again to re-create tables and seed data

The user's local PostgreSQL password is `r2d2m`, configured in `server/.env`.

3. Key Technical Concepts:

- __Go server__: Gin HTTP framework + Ent ORM for PostgreSQL, JWT auth (access+refresh tokens), bcrypt passwords
- __Ent ORM__: Auto-migration creates tables (uses IDENTITY columns, NOT SERIAL — this caused a conflict when SQL schema.sql was run first)
- __Flutter app__: Provider state management, Material Design 3, Rostelecom purple branding
- __4 roles__: admin, dispatcher, technician, supervisor with RBAC middleware
- __Request lifecycle__: new → assigned → in_progress → completed/cancelled
- __Local connectivity__: Android emulator uses 10.0.2.2:8080, Chrome/desktop uses localhost:8080
- __AndroidManifest.xml__: `usesCleartextTraffic="true"` and INTERNET permission added for local HTTP

4. Relevant Files and Code:

__Project Root__ (`c:\Users\User\Desktop\RaidaPraktik\rostelecom_app`):

- `Readme.md` — Full documentation with local setup instructions
- `docker-compose.yml` — PostgreSQL + Go server (optional)
- `database/schema.sql` — Reference SQL schema (10 tables, 3NF) — NOT used for actual table creation (Ent does that)
- `start_server.bat` — Launches Go server with auto DB check
- `start_app.bat` — Launches Flutter app
- `build_release_apk.bat` — Builds release APK
- `Otchet/Отчёт.md` — Full practice report (6 chapters)

__Go Server__ (`rostelecom_app/server/`):

- `cmd/server/main.go` — Entry point, routes, CORS, handlers setup
- `go.mod` — Module `rostelecom-server`, Go 1.23, deps: ent v0.14.6, gin v1.12.0, jwt/v5, godotenv, lib/pq, crypto
- `.env` — DB_PASSWORD=r2d2m, DB_NAME=rostelecom_requests, SERVER_PORT=8080
- `Dockerfile` — Multi-stage Alpine build
- `internal/config/config.go` — Config from env vars (DB, JWT, Server)
- `internal/middleware/auth.go` — JWT Claims (UserID, Login, RoleName), GenerateAccessToken, AuthMiddleware
- `internal/middleware/rbac.go` — RequireRole, RequireAdmin, RequireRequestManager
- `internal/seed/seed.go` — Seeds roles, service types, statuses, categories, 5 users, 10 requests with addresses/history/notifications
- `internal/handler/auth.go` — Login, RefreshToken, Logout
- `internal/handler/request.go` — List (with filters/search/role-based), Get, Create, Update, Delete, History, ExportCSV, formatRequest helper
- `internal/handler/notification.go` — List, MarkRead, MarkAllRead
- `internal/handler/profile.go` — GetProfile
- `internal/handler/reference.go` — GetServiceTypes, GetStatuses, GetCategories, GetRoles, GetTechnicians
- `internal/handler/admin.go` — ListUsers, CreateUser, UpdateUser, DeleteUser
- `ent/schema/` — 10 schemas: role.go, user.go, servicetype.go, requeststatus.go, requestcategory.go, address.go, request.go, requesthistory.go, notification.go, refreshtoken.go
- `ent/generate.go` — `//go:generate go run -mod=mod entgo.io/ent/cmd/ent generate ./schema`

__Flutter App__ (`rostelecom_app/mobile_app/`):

- `pubspec.yaml` — Dependencies: provider, http, shared_preferences, intl, flutter_secure_storage
- `lib/main.dart` — RostelecomApp with MultiProvider, AuthGate, routes (/login, /home, /admin-users)
- `lib/config/environment.dart` — Auto-detects API URL by platform (kIsWeb→localhost, Android→10.0.2.2, etc.)
- `lib/core/constants.dart` — AppColors (Rostelecom purple palette), ApiConfig (all endpoint URLs)
- `lib/core/api_client.dart` — Static HTTP client with JWT, auto-refresh, FlutterSecureStorage
- `lib/models/user_model.dart` — UserModel with roleLabel, initials, permission helpers
- `lib/models/request_model.dart` — RequestModel + ServiceTypeRef, CategoryRef, StatusRef, AddressRef, AssigneeRef, CreatorRef, NotificationModel, HistoryEntry
- `lib/providers/auth_provider.dart` — login, logout, loadProfile, tryAutoLogin
- `lib/providers/request_provider.dart` — loadRequests, loadRequest, loadHistory, createRequest, updateRequest, deleteRequest, loadReferences
- `lib/screens/login_screen.dart` — Animated login with gradient, Rostelecom branding
- `lib/screens/home_screen.dart` — 3-tab navigation (Requests, Notifications, Profile), search, status filter chips, request cards
- `lib/screens/request_detail_screen.dart` — Full detail view with status/info/client/address/assignee/actions/history cards
- `lib/screens/create_request_screen.dart` — Form with dropdowns for service type, category, technician
- `lib/screens/notifications_screen.dart` — Notification list with mark read/all
- `lib/screens/profile_screen.dart` — Profile info, admin panel link, logout
- `lib/screens/admin_users_screen.dart` — User management with create/toggle/delete
- `android/app/src/main/AndroidManifest.xml` — INTERNET permission, usesCleartextTraffic=true, label="Ростелеком Заявки"

5. Problem Solving:

- __Ent vs SQL schema conflict__: Ent uses IDENTITY columns, schema.sql used SERIAL. Solution: Don't run schema.sql manually — let Ent auto-migrate from scratch.
- __DB password__: User's local PostgreSQL password is `r2d2m`, updated in .env
- __psql not in PATH__: Found at `C:\Program Files\PostgreSQL\18\bin\psql.exe`
- __Port conflict__: Server started twice causing bind error — only run one instance
- __PowerShell && operator__: Not supported, use `;` separator instead
- __Flutter analyze__: 0 errors, only info/warnings (deprecated `value` parameter, unused field)
- __DB reset__: Used `DROP SCHEMA public CASCADE; CREATE SCHEMA public;` via psql

6. Pending Tasks and Next Steps: All requested tasks have been completed:

- ✅ Full project created (Go server + Flutter app + PostgreSQL)
- ✅ Test data seeding (10 requests, addresses, history, notifications)
- ✅ Notifications verified working
- ✅ Practice report written

The user needs to __restart the server__ after the DB reset to load seed data (the DB schema was dropped but the server wasn't restarted yet — current server shows 401 on login because users table is empty). Steps: Ctrl+C in terminal → run `start_server.bat`.
