#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting deployment..."

# 0. Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found! Please create it from .env.example"
    exit 1
fi

# 1. Build and start containers
echo "📦 Building and starting containers..."
docker-compose up -d --build

echo "⏳ Waiting for database to be ready..."
# Better way to wait for DB
until docker-compose exec -T postgres-postgis pg_isready -U $(grep DB_USER .env | cut -d '=' -f2 || echo "diplom_user") > /dev/null 2>&1; do
  echo "Still waiting for Postgres..."
  sleep 2
done

# 2. Run migrations
echo "⚙️ Running migrations..."
docker-compose exec -T django-app python manage.py migrate --noinput

# 3. Collect static files
echo "static Collecting static files..."
docker-compose exec -T django-app python manage.py collectstatic --noinput

# 4. Create superuser if it doesn't exist
echo "👤 Create superuser (interactive if needed)..."
echo "You can skip this if you already have one."
docker-compose exec django-app python manage.py createsuperuser || true

echo "✅ Deployment finished successfully!"
echo "Note: If this is your first run and you need SSL, run: ./init-letsencrypt.sh yourdomain.com your@email.com"
