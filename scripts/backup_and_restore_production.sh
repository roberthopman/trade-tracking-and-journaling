#!/bin/bash
# frozen_string_literal: true

# Script to backup production database and restore it locally
# Usage: ./scripts/backup_and_restore_production.sh

set -e

APP_NAME="WRITEYOURAPPNAME"
BACKUP_DIR="scripts/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/production_$TIMESTAMP.dump"

echo "🔄 Creating backup directory..."
mkdir -p "$BACKUP_DIR"

echo "📦 Creating Heroku backup..."
heroku pg:backups:capture --app "$APP_NAME"

echo "⬇️  Downloading backup..."
heroku pg:backups:download b001 --app "$APP_NAME" --output "$BACKUP_FILE"

echo "🗑️  Dropping local database..."
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 RAILS_ENV=development rails db:drop

echo "🔄 Creating local database..."
RAILS_ENV=development rails db:create

echo "📥 Restoring from backup..."
pg_restore --verbose --no-acl --no-owner -d payout_development "$BACKUP_FILE"

echo "🚀 Running migrations..."
RAILS_ENV=development rails db:migrate

echo "🔧 Running space backfill..."
RAILS_ENV=development rake spaces:backfill

echo "✅ Done! Database restored and configured."
echo "📁 Backup saved to: $BACKUP_FILE"