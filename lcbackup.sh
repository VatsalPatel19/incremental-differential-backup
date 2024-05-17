#!/bin/bash

echo "Starting backup script..."

# Define username and paths
username="patel7c9"
backup_root="/home/$username/Assignment"
complete_backup_dir="$HOME/backup/cbw24"
incremental_backup_dir="$HOME/backup/ib24"
differential_backup_dir="$HOME/backup/db24"
log_file="$HOME/backup/backup.log"

echo "Creating necessary directories..."
mkdir -p "$complete_backup_dir" "$incremental_backup_dir" "$differential_backup_dir"

# Logging function with specific date and time format
log_backup() {
    local message="$1"
    local timestamp=$(date "+%a %d %b %Y %I:%M:%S %p %Z")
    echo "$timestamp $message" >> "$log_file"
    echo "Log updated: $message"
}

# Function to create checksums of all files in directory
create_checksums() {
    local directory="$1"
    local checksum_file="$2"
    find "$directory" -type f -exec md5sum {} + | sort > "$checksum_file"
}

# Perform a complete backup
perform_complete_backup() {
    local backup_file="cbw24-$(date '+%Y%m%d%H%M%S').tar"
    echo "Performing complete backup..."
    tar -cvpf "$complete_backup_dir/$backup_file" "$backup_root" > /dev/null 2>&1
    log_backup "$backup_file was created"
    create_checksums "$backup_root" "$complete_backup_dir/metadata.txt"
    echo "Complete backup completed."
}

# Perform an incremental backup
perform_incremental_backup() {
    local last_metadata="$1"
    local backup_dir="$2"
    local backup_file_prefix="$3"
    local new_metadata="$backup_dir/metadata.txt"

    echo "Checking for changes..."
    create_checksums "$backup_root" "$new_metadata"
    local backup_file="$backup_file_prefix-$(date '+%Y%m%d%H%M%S').tar"
    local changes=$(comm -13 "$last_metadata" "$new_metadata" | awk '{print $2}')

    if [ -z "$changes" ]; then
        log_backup "No changes - Incremental backup was not created"
        echo "No changes detected. Incremental backup not needed."
    else
        echo "Changes detected. Performing incremental backup..."
        echo "$changes" | xargs -d '\n' tar -cvpf "$backup_dir/$backup_file" > /dev/null 2>&1
        log_backup "$backup_file was created"
        echo "Incremental backup completed."
    fi
}

# Perform a differential backup
perform_differential_backup() {
    echo "Performing differential backup..."
    perform_incremental_backup "$complete_backup_dir/metadata.txt" "$differential_backup_dir" "dbw24"
    echo "Differential backup completed."
}

# Main loop
while true; do
    echo "Starting complete backup..."
    perform_complete_backup

    sleep 120 # 2 minutes interval
    echo "Starting incremental backup after STEP 1..."
    perform_incremental_backup "$complete_backup_dir/metadata.txt" "$incremental_backup_dir" "ibw24"

    sleep 120 # 2 minute interval
    echo "Starting incremental backup after STEP 2..."
    perform_incremental_backup "$incremental_backup_dir/metadata.txt" "$incremental_backup_dir" "ibw24"

    sleep 120 # 2 minute interval
    echo "Starting differential backup after STEP 1..."
    perform_differential_backup

    sleep 120 # 2 minute interval
    echo "Starting incremental backup after STEP 4..."
    perform_incremental_backup "$differential_backup_dir/metadata.txt" "$incremental_backup_dir" "ibw24"

    # Return to STEP 1
    echo "Cycle complete. Restarting backup cycle..."
done

echo "Backup script ended."
