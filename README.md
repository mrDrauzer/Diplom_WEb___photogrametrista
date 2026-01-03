# Фотограмметрия: Docker Инфраструктура

Полноценный Docker-стек для Django проекта с поддержкой PostGIS, Redis, Celery и автоматическим SSL через Let's Encrypt.

## Технологический стек
- **Django 5.x** + **Gunicorn** (Python 3.12)
- **PostgreSQL 15** + **PostGIS 3.4** (Геоданные)
- **Redis 7** (Брокер для Celery)
- **Celery** (Фоновые задачи: загрузка с Яндекс.Диска, обработка фото)
- **Nginx** (Проксирование и статика)
- **Certbot** (SSL сертификаты Let's Encrypt)
- **Prometheus & Grafana** (Мониторинг и метрики)
- **Loki & Promtail** (Сбор и анализ логов)

## Структура файлов
- `docker-compose.yml` - Описание всех сервисов.
- `Dockerfile.django` - Оптимизированный multi-stage build.
- `nginx/nginx.conf` - Конфигурация веб-сервера (HTTP/HTTPS).
- `deploy.sh` - Скрипт быстрого деплоя (миграции, статика).
- `init-letsencrypt.sh` - Инициализация SSL сертификатов.
- `backup.sh` - Скрипт для бэкапа базы данных.
- `.env.example` - Шаблон переменных окружения.

## Быстрый старт (Ubuntu/Debian)

### 1. Подготовка сервера
```bash
sudo apt update && sudo apt install -y docker.io docker-compose git
git clone git@github.com:mrDrauzer/Diplom_WEb___photogrametrista.git
cd Diplom_WEb___photogrametrista
```

### 2. Настройка переменных
```bash
cp .env.example .env
nano .env
```
Обязательно укажите:
- `POSTGRES_PASSWORD`
- `YADISK_TOKEN`
- `DOMAIN_NAME` (ваш домен)
- `EMAIL` (для Let's Encrypt)

### 3. Первый запуск с SSL
Если у вас есть домен и он направлен на сервер:
```bash
chmod +x init-letsencrypt.sh
./init-letsencrypt.sh yourdomain.com your@email.com
```

Если вы хотите запустить локально без SSL (только HTTP):
```bash
chmod +x deploy.sh
./deploy.sh
```

## Обслуживание

### Бэкап базы данных
Скрипт создает SQL дамп в папке `./backups` и удаляет бэкапы старше 7 дней.
```bash
chmod +x backup.sh
./backup.sh
```

### Добавление в Cron (авто-бэкап)
```bash
crontab -e
# Добавьте строку для ежедневного бэкапа в 3 часа ночи
0 3 * * * cd /path/to/project && ./backup.sh
```

### Логи
```bash
docker-compose logs -f django-app
docker-compose logs -f celery-worker
```

## Мониторинг
После запуска проекта доступны следующие панели:
- **Prometheus**: `http://your-server-ip:9090` (сбор метрик)
- **Grafana**: `http://your-server-ip:3000` (визуализация)
  - Дефолтный логин: `admin`
  - Пароль: `admin_secure_password` (задается в `.env`)

### Логи (Loki)
Логи всех контейнеров автоматически собираются в Loki. Чтобы просмотреть их:
1. Зайдите в Grafana.
2. Перейдите в **Explore**.
3. Выберите источник данных **Loki**.
4. Используйте Log Browser для выбора нужного контейнера (например, `{container="django-app"}`).

Для интеграции с Django:
1. Добавьте `'django_prometheus'` в `INSTALLED_APPS` в `settings.py`.
2. Добавьте middleware `django_prometheus.middleware.PrometheusBeforeMiddleware` (в начало) и `django_prometheus.middleware.PrometheusAfterMiddleware` (в конец).
3. Добавьте `path('', include('django_prometheus.urls'))` в `urls.py`.

## CI/CD
В проекте настроен GitHub Actions (`.github/workflows/deploy.yml`). 
Для работы добавьте следующие секреты в ваш GitHub репозиторий:
- `SERVER_HOST`: IP вашего сервера
- `SERVER_USER`: Пользователь (напр. root)
- `SSH_PRIVATE_KEY`: Приватный SSH ключ для доступа к серверу

## Разработка
Для запуска локально в режиме разработки (с горячей перезагрузкой):
1. Измените `DEBUG=True` в `.env`
2. Переопределите `command` в `docker-compose.override.yml` на `python manage.py runserver 0.0.0.0:8000`

## Безопасность (Security)
Для обеспечения максимальной безопасности в Production:
1. **Django Settings**:
   - Установите `SECURE_SSL_REDIRECT = True`
   - Установите `SESSION_COOKIE_SECURE = True`
   - Установите `CSRF_COOKIE_SECURE = True`
   - Установите `SECURE_HSTS_SECONDS = 31536000`
2. **Пароли**: Регулярно меняйте пароли в `.env`.
3. **Обновления**: Регулярно обновляйте Docker-образы (`docker-compose pull`).
