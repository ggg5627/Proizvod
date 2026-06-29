-- ============================================================
-- Ростелеком — Управление заявками абонентов
-- Схема базы данных PostgreSQL (3НФ)
-- ============================================================

-- ========================
-- 1. Справочник ролей
-- ========================
CREATE TABLE IF NOT EXISTS roles (
    id            SMALLSERIAL PRIMARY KEY,
    name          VARCHAR(50) NOT NULL UNIQUE,
    display_name  VARCHAR(100) NOT NULL
);

INSERT INTO roles (name, display_name) VALUES
    ('admin',       'Администратор'),
    ('dispatcher',  'Диспетчер'),
    ('technician',  'Выездной техник'),
    ('supervisor',  'Руководитель')
ON CONFLICT (name) DO NOTHING;

-- ========================
-- 2. Справочник типов услуг
-- ========================
CREATE TABLE IF NOT EXISTS service_types (
    id    SMALLSERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO service_types (name) VALUES
    ('Интернет'),
    ('Цифровое ТВ'),
    ('Телефония'),
    ('Видеонаблюдение')
ON CONFLICT (name) DO NOTHING;

-- ========================
-- 3. Справочник статусов заявок
-- ========================
CREATE TABLE IF NOT EXISTS request_statuses (
    id     SMALLSERIAL PRIMARY KEY,
    name   VARCHAR(50) NOT NULL UNIQUE,
    color  VARCHAR(7) NOT NULL DEFAULT '#9E9E9E'
);

INSERT INTO request_statuses (name, color) VALUES
    ('new',         '#2196F3'),
    ('assigned',    '#FF9800'),
    ('in_progress', '#9C27B0'),
    ('completed',   '#4CAF50'),
    ('cancelled',   '#F44336')
ON CONFLICT (name) DO NOTHING;

-- ========================
-- 4. Справочник категорий заявок
-- ========================
CREATE TABLE IF NOT EXISTS request_categories (
    id    SMALLSERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO request_categories (name) VALUES
    ('Подключение'),
    ('Ремонт'),
    ('Консультация'),
    ('Модернизация')
ON CONFLICT (name) DO NOTHING;

-- ========================
-- 5. Пользователи
-- ========================
CREATE TABLE IF NOT EXISTS users (
    id             SERIAL PRIMARY KEY,
    full_name      VARCHAR(200) NOT NULL,
    login          VARCHAR(100) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    role_id        SMALLINT NOT NULL REFERENCES roles(id),
    phone          VARCHAR(20) DEFAULT '',
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ========================
-- 6. Адреса
-- ========================
CREATE TABLE IF NOT EXISTS addresses (
    id         SERIAL PRIMARY KEY,
    city       VARCHAR(100) NOT NULL DEFAULT 'Москва',
    street     VARCHAR(200) NOT NULL,
    house      VARCHAR(20) NOT NULL,
    apartment  VARCHAR(20) DEFAULT '',
    entrance   VARCHAR(10) DEFAULT '',
    floor      VARCHAR(10) DEFAULT ''
);

-- ========================
-- 7. Заявки
-- ========================
CREATE TABLE IF NOT EXISTS requests (
    id               SERIAL PRIMARY KEY,
    title            VARCHAR(300) NOT NULL,
    description      TEXT DEFAULT '',
    service_type_id  SMALLINT NOT NULL REFERENCES service_types(id),
    category_id      SMALLINT NOT NULL REFERENCES request_categories(id),
    status_id        SMALLINT NOT NULL REFERENCES request_statuses(id) DEFAULT 1,
    address_id       INTEGER REFERENCES addresses(id),
    client_name      VARCHAR(200) NOT NULL,
    client_phone     VARCHAR(20) NOT NULL,
    assigned_to      INTEGER REFERENCES users(id),
    created_by       INTEGER NOT NULL REFERENCES users(id),
    scheduled_at     TIMESTAMPTZ,
    completed_at     TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_requests_status ON requests(status_id);
CREATE INDEX IF NOT EXISTS idx_requests_assigned ON requests(assigned_to);
CREATE INDEX IF NOT EXISTS idx_requests_created_by ON requests(created_by);

-- ========================
-- 8. История изменений заявок
-- ========================
CREATE TABLE IF NOT EXISTS request_history (
    id             SERIAL PRIMARY KEY,
    request_id     INTEGER NOT NULL REFERENCES requests(id) ON DELETE CASCADE,
    user_id        INTEGER NOT NULL REFERENCES users(id),
    old_status_id  SMALLINT REFERENCES request_statuses(id),
    new_status_id  SMALLINT REFERENCES request_statuses(id),
    comment        TEXT DEFAULT '',
    changed_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_request_history_request ON request_history(request_id);

-- ========================
-- 9. Уведомления
-- ========================
CREATE TABLE IF NOT EXISTS notifications (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    request_id  INTEGER REFERENCES requests(id) ON DELETE SET NULL,
    message     TEXT NOT NULL,
    is_read     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);

-- ========================
-- 10. Refresh-токены (для JWT)
-- ========================
CREATE TABLE IF NOT EXISTS refresh_tokens (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token       VARCHAR(500) NOT NULL UNIQUE,
    expires_at  TIMESTAMPTZ NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
