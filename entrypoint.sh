#!/bin/sh
set -e

CONFIG_DIR="/etc/config/oathkeeper"
TEMP_CONFIG_DIR=$(mktemp -d)
export CONF_DIR=${TEMP_CONFIG_DIR}

# Function to process a single file
process_file() {
    local src_file="$1"
    local rel_path="${src_file#$CONFIG_DIR/}"
    local dest_file="$TEMP_CONFIG_DIR/$rel_path"
    local dest_dir=$(dirname "$dest_file")

    mkdir -p "$dest_dir"
    envsubst < "$src_file" > "$dest_file"
    echo "Processed: $src_file -> $dest_file"
}

# Initial processing of all files in the config dir
find "$CONFIG_DIR" -type f | while read -r file; do
    process_file "$file"
done

# Start file watching in the background
(
    inotifywait -m -r -e modify,create,delete "$CONFIG_DIR" |
        while read -r directory events filename; do
            echo "Detected $events on $directory$filename"
            process_file "$directory$filename"
        done
) &

# Start Oathkeeper
exec oathkeeper serve proxy -c "$TEMP_CONFIG_DIR/oathkeeper.yml" "$@"