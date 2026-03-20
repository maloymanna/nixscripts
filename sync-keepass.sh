#!/bin/bash

# Configuration
LOCAL_FILE="$HOME/Documents/KeePass.kdbx"   # <-- KeePass path
GOOGLEDRIVE_REMOTE="googledrive:KeePass/"   # Folder in Google Drive
ONEDRIVE_REMOTE="onedrive:KeePass/"         # Folder in OneDrive

# Ensure destination folders exist
rclone mkdir "$GOOGLEDRIVE_REMOTE"
rclone mkdir "$ONEDRIVE_REMOTE"

# Function to sync file
sync_file() {
    echo "$(date): File changed. Syncing to cloud..."
    
    # Upload to Google Drive
    rclone copy "$LOCAL_FILE" "$GOOGLEDRIVE_REMOTE" --progress
    if [ $? -eq 0 ]; then
        echo "$(date): ✅ Sync to Google Drive successful."
    else
        echo "$(date): ❌ Failed to sync to Google Drive."
    fi

    # Upload to OneDrive
    rclone copy "$LOCAL_FILE" "$ONEDRIVE_REMOTE" --progress
    if [ $? -eq 0 ]; then
        echo "$(date): ✅ Sync to OneDrive successful."
    else
        echo "$(date): ❌ Failed to sync to OneDrive."
    fi
}

# Optional initial sync
echo "Starting watcher for: $LOCAL_FILE"
sync_file
# echo "Exiting" # Uncomment if using in a one-shot manner

# Watch for modifications - comment out this section if not scheduled
inotifywait -m -e close_write --format '%w%f' "$LOCAL_FILE" | while read FILE
do
    if [ "$FILE" = "$LOCAL_FILE" ]; then
        sync_file
    fi
done
