#!/bin/bash
# frozen_string_literal: true

# Script to restore from existing backup file
# Usage: ./scripts/restore_from_backup.sh [backup_file]

set -e

BACKUP_DIR="scripts/backups"

if [ $# -eq 0 ]; then
    # Find the most recent backup
    BACKUP_FILE=$(ls -t "$BACKUP_DIR"/production_*.dump | head -n1)
    if [ -z "$BACKUP_FILE" ]; then
        echo "❌ No backup files found in $BACKUP_DIR"
        echo "Run ./scripts/backup_and_restore_production.sh first"
        exit 1
    fi
    echo "📁 Using most recent backup: $(basename "$BACKUP_FILE")"
else
    BACKUP_FILE="$1"
    if [ ! -f "$BACKUP_FILE" ]; then
        echo "❌ Backup file not found: $BACKUP_FILE"
        exit 1
    fi
fi

echo "🗑️  Dropping local database..."
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=development rails db:drop

echo "🔄 Creating local database..."
RAILS_ENV=development rails db:create

echo "📥 Restoring from backup: $(basename "$BACKUP_FILE")"
pg_restore --verbose --no-acl --no-owner -d payout_development "$BACKUP_FILE"

echo "🚀 Running migrations..."
RAILS_ENV=development rails db:migrate

echo "🔧 Running space backfill..."
RAILS_ENV=development rake spaces:backfill

echo "✅ Done! Database restored and configured."