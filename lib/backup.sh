#!/bin/bash

###############################################################################
# Backup Functions                                                              #
###############################################################################

# Initialize backup directories
init_backup_dirs() {
    if ! mkdir -p "$BACKUP_DIR"; then
        echo "Error: Failed to create backup directory"
        return 1
    fi
    
    if ! mkdir -p "$PREFS_BACKUP_DIR"; then
        echo "Error: Failed to create preferences backup directory"
        return 1
    fi
}

# Backup system preferences
backup_preferences() {
    echo "Backing up system preferences..."
    
    local pref_domains=(
        "com.apple.dock"
        "com.apple.finder"
        "com.apple.systempreferences"
        "NSGlobalDomain"
        ".GlobalPreferences"
    )
    
    for domain in "${pref_domains[@]}"; do
        if ! defaults export "$domain" "$PREFS_BACKUP_DIR/${domain}.plist" 2>/dev/null; then
            echo "Warning: Failed to backup preferences for $domain"
        fi
    done
}

# Main backup function
backup_configs() {
    local backup_dir="${HOME}/.mac-deploy-backup/$(date +%Y%m%d_%H%M%S)"
    printf "Backing up configurations to %s...\n" "$backup_dir"
    
    # Create backup directory
    if ! mkdir -p "$backup_dir"; then
        printf "%bFailed to create backup directory%b\n" "$RED" "$NC"
        return 1
    fi
    
    # Create subdirectories
    mkdir -p "$backup_dir/preferences"
    mkdir -p "$backup_dir/dotfiles"
    
    # Backup preferences
    if ! backup_preferences "$backup_dir/preferences"; then
        printf "%bFailed to backup preferences%b\n" "$RED" "$NC"
        return 1
    fi
    
    # Backup dotfiles
    if ! backup_dotfiles "$backup_dir/dotfiles"; then
        printf "%bFailed to backup dotfiles%b\n" "$RED" "$NC"
        return 1
    fi
    
    printf "%bBackup completed successfully%b\n" "$GREEN" "$NC"
    return 0
} 