#!/usr/bin/env bash
# Quick backup script for important files

BACKUP_DIR="$HOME/Backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup important directories
echo "Backing up to $BACKUP_DIR..."
rsync -av --progress ~/.ssh/ "$BACKUP_DIR/ssh/"
rsync -av --progress ~/.gnupg/ "$BACKUP_DIR/gnupg/"
rsync -av --progress ~/.config/ "$BACKUP_DIR/config/"
rsync -av --progress ~/.dotfiles/ "$BACKUP_DIR/dotfiles/"

# Create a list of installed brew packages
brew bundle dump --file="$BACKUP_DIR/Brewfile" --force

echo "Backup complete!"
