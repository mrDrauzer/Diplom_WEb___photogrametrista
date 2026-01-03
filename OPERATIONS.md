# Шпаргалка по управлению (Cheat Sheet)

Данный файл содержит основные команды для управления и обслуживания инфраструктуры проекта.

## 🛠 Управление контейнерами

*   **Просмотр статуса всех сервисов:**
    ```bash
    docker-compose ps
    ```
*   **Запуск всех сервисов:**
    ```bash
    docker-compose up -d
    ```
*   **Остановка всех сервисов:**
    ```bash
    docker-compose down
    ```
*   **Перезапуск конкретного сервиса (например, Django):**
    ```bash
    docker-compose restart django-app
    ```
*   **Просмотр логов в реальном времени:**
    ```bash
    docker-compose logs -f django-app
    ```

## 🐍 Django и База данных

*   **Вход в shell Django:**
    ```bash
    docker-compose exec django-app python manage.py shell
    ```
*   **Создание суперпользователя:**
    ```bash
    docker-compose exec django-app python manage.py createsuperuser
    ```
*   **Применение миграций вручную:**
    ```bash
    docker-compose exec django-app python manage.py migrate
    ```
*   **Сбор статики вручную:**
    ```bash
    docker-compose exec django-app python manage.py collectstatic --noinput
    ```
*   **Вход в консоль PostgreSQL:**
    ```bash
    docker-compose exec postgres-postgis psql -U ${DB_USER:-diplom_user} -d ${DB_NAME:-diplom_db}
    ```

## 🚀 Масштабирование и обновление

*   **Масштабирование воркеров Celery:**
    ```bash
    docker-compose up -d --scale celery-worker=3
    ```
*   **Обновление кода (после git pull):**
    ```bash
    ./deploy.sh
    ```

## 🔍 Мониторинг и Логирование

*   **Grafana:** `http://your-ip:3000` (Логи в разделе Explore -> Loki)
*   **Prometheus:** `http://your-ip:9090` (Метрики)
*   **Проверка продления SSL:**
    ```bash
    docker-compose run --rm certbot renew
    ```

## 💾 Резервное копирование

*   **Ручной запуск бэкапа:**
    ```bash
    ./backup.sh
    ```
    *Дампы сохраняются в папку `./backups`*

## ⚠️ Решение проблем (Troubleshooting)

1.  **Контейнер падает с ошибкой:** Проверьте логи через `docker-compose logs <service_name>`.
2.  **Ошибка БД:** Убедитесь, что пароли в `.env` совпадают с теми, что использовались при первом запуске (инициализации тома `postgres_data`).
3.  **Nginx не стартует:** Возможно, не созданы SSL сертификаты. Используйте `./init-letsencrypt.sh`.
