#!/bin/bash
set -eEuo pipefail

# Migration: Fix webapp desktop files to use absolute paths

echo "Fixing webapp desktop files"

RIG_BIN="$HOME/.rig/unix/fedora/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

# Validate paths
if [[ ! -d "$RIG_BIN" ]]; then
    echo "[ERROR] Rig bin directory not found: $RIG_BIN"
    exit 1
fi

if [[ ! -d "$DESKTOP_DIR" ]]; then
    echo "[INFO] Desktop applications directory not found, nothing to migrate"
    exit 0
fi

# Track changes
declare -i fixed=0

# Fix all desktop files that use rig-launch-webapp without full path
for desktop_file in "$DESKTOP_DIR"/*.desktop; do
    [[ -f "$desktop_file" ]] || continue

    # Check if file uses relative path to rig-launch-webapp
    if grep -q "^Exec=rig-launch-webapp " "$desktop_file" 2>/dev/null; then
        # Check if already fixed
        if grep -q "^Exec=$RIG_BIN/rig-launch-webapp " "$desktop_file" 2>/dev/null; then
            echo "[INFO] Already fixed: $(basename "$desktop_file")"
            continue
        fi

        echo "[INFO] Fixing: $(basename "$desktop_file")"

        # Backup before modification
        cp "$desktop_file" "${desktop_file}.bak"

        # Use more precise sed
        if sed -i "s|^Exec=rig-launch-webapp |Exec=$RIG_BIN/rig-launch-webapp |" "$desktop_file"; then
            fixed=$((fixed + 1))
        else
            echo "[WARNING] Failed to fix: $(basename "$desktop_file")"
            # Restore backup
            mv "${desktop_file}.bak" "$desktop_file"
        fi
    fi
done

echo "[SUCCESS] Migration completed: Fixed $fixed webapp desktop files"
