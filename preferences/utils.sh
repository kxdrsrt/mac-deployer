#!/bin/bash

# Load all preference files
source_preference_files() {
    local prefs_dir="${SCRIPT_DIR}/preferences"
    for pref_file in "$prefs_dir"/*.sh; do
        if [[ -f "$pref_file" ]]; then
            source "$pref_file"
        fi
    done
}

# Apply preference setting
apply_setting() {
    local domain=$1
    local key=$2
    local value=$3
    local type=$4

    # Validate inputs
    [[ -z "$domain" || -z "$key" || -z "$value" ]] && {
        echo "Error: Missing required parameters"
        return 1
    }

    if [[ -n "$type" ]]; then
        defaults write "$domain" "$key" "-$type" "$value" || {
            echo "Error writing setting: $domain $key"
            return 1
        }
    else
        defaults write "$domain" "$key" "$value" || {
            echo "Error writing setting: $domain $key"
            return 1
        }
    fi
} 