#!/bin/bash

###############################################################################
# Preferences Management Functions                                              #
###############################################################################

# Source required configurations
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Function to configure Mac preferences
configure_mac_prefs() {
    printf "Configuring Mac preferences...\n"
    
    # Configure Finder preferences
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Configure Dock preferences
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock tilesize -int 36
    
    # Add more preference configurations as needed
    
    printf "Mac preferences configured successfully\n"
    return 0
}

# Function to configure animation preferences
configure_animation_prefs() {
    printf "Configuring animation preferences...\n"
    
    # Disable animations
    defaults write com.apple.dock expose-animation-duration -float 0.1
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    
    # Add more animation configurations as needed
    
    printf "Animation preferences configured successfully\n"
    return 0
}

# Function to backup preferences
backup_preferences() {
    local backup_dir="$1"
    printf "Backing up preferences to %s...\n" "$backup_dir"
    
    # Create backup directory
    if ! mkdir -p "$backup_dir"; then
        printf "Failed to create preferences backup directory\n"
        return 1
    fi
    
    # Backup important plist files
    local plist_files=(
        "$HOME/Library/Preferences/com.apple.finder.plist"
        "$HOME/Library/Preferences/com.apple.dock.plist"
        # Add more plist files as needed
    )
    
    for plist in "${plist_files[@]}"; do
        if [[ -f "$plist" ]]; then
            cp "$plist" "$backup_dir/" || {
                printf "Failed to backup %s\n" "$plist"
                return 1
            }
        fi
    done
    
    printf "Preferences backup completed successfully\n"
    return 0
}

# Rest of the file... 