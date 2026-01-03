#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | xargs)
fi

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FILENAME="backup_${DB_NAME}_${TIMESTAMP}.sql"

mkdir -p ${BACKUP_DIR}

echo "Starting backup of ${DB_NAME}..."

docker-compose exec -t postgres-postgis pg_dump -U ${DB_USER:-diplom_user} ${DB_NAME:-diplom_db} > ${BACKUP_DIR}/${FILENAME}

if [ $? -eq 0 ]; then
    echo "Backup successful: ${BACKUP_DIR}/${FILENAME}"
    # Keep only last 7 days of backups
    find ${BACKUP_DIR} -name "*.sql" -type f -mtime +7 -delete
    echo "Old backups cleaned up."
else
    echo "Backup failed!"
    exit 1
fi
