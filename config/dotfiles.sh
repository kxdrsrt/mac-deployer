#!/bin/bash

###############################################################################
# Dotfiles Configuration                                                        #
###############################################################################

# Only set DOTFILES_REPO if it's not already defined
if [[ -z "${DOTFILES_REPO+x}" ]]; then
    DOTFILES_REPO="your_default_value_here"
fi

# Only set DOTFILES_BRANCH if it's not already defined
if [[ -z "${DOTFILES_BRANCH+x}" ]]; then
    DOTFILES_BRANCH="main"
fi

# Use different variable names for backup paths specific to dotfiles
DOTFILES_BACKUP_PATH="${HOME}/.mac-deploy-backup/$(date +%Y%m%d_%H%M%S)"
DOTFILES_BACKUP_SUBDIR="${DOTFILES_BACKUP_PATH}/dotfiles"
DOTFILES_PREFS_SUBDIR="${DOTFILES_BACKUP_PATH}/preferences"

setup_dotfiles() {
    echo "Setting up dotfiles..."
    
    # Validate repository URL
    if [[ ! "$DOTFILES_REPO" =~ ^https?:// ]]; then
        echo "Error: Invalid dotfiles repository URL"
        return 1
    fi
    
    # Create backup directory with error checking
    if ! mkdir -p "$DOTFILES_BACKUP_SUBDIR"; then
        echo "Error: Failed to create backup directory"
        return 1
    fi
    
    # Backup existing dotfiles with error handling
    echo "Backing up current dotfiles to ${DOTFILES_BACKUP_SUBDIR}"
    for file in .zshrc .bashrc .bash_profile .gitconfig .config .vscode; do
        if [[ -e "$HOME/$file" ]]; then
            if ! cp -R "$HOME/$file" "$DOTFILES_BACKUP_SUBDIR/"; then
                echo "Error: Failed to backup $file"
                return 1
            fi
        fi
    done
    
    # Create temporary directory with error handling
    local temp_dir
    if ! temp_dir=$(mktemp -d); then
        echo "Error: Failed to create temporary directory"
        return 1
    fi
    
    # Clone repository
    if ! git clone -b "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$temp_dir"; then
        echo "Error: Failed to clone dotfiles repository"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Copy everything to home directory with error handling
    if ! cp -R "$temp_dir/." "$HOME/"; then
        echo "Error: Failed to copy dotfiles to home directory"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Cleanup with error handling
    if ! rm -rf "$temp_dir"; then
        echo "Warning: Failed to clean up temporary directory: $temp_dir"
    fi
    
    echo "Dotfiles setup complete (backup at ${DOTFILES_BACKUP_SUBDIR})"
    return 0
}

restore_backup() {
    local backup_date=$1
    local backup_path="${HOME}/.mac-deploy-backup/${backup_date}"
    
    if [[ ! -d "$backup_path" ]]; then
        echo "Error: Backup not found at ${backup_path}"
        return 1
    fi
    
    if [[ -d "${backup_path}/dotfiles" ]]; then
        echo "Restoring dotfiles from ${backup_path}/dotfiles"
        if ! cp -R "${backup_path}/dotfiles/." "$HOME/"; then
            echo "Error: Failed to restore dotfiles"
            return 1
        fi
    fi
    
    if [[ -d "${backup_path}/preferences" ]]; then
        echo "Restoring preferences from ${backup_path}/preferences"
        if ! restore_preferences "${backup_path}/preferences"; then
            echo "Error: Failed to restore preferences"
            return 1
        fi
    fi
    
    echo "Backup restoration completed successfully"
    return 0
}

restore_preferences() {
    local prefs_backup_dir="$1"
    
    if [[ ! -d "$prefs_backup_dir" ]]; then
        echo "Error: Preferences backup directory not found"
        return 1
    fi
    
    # Restore each preference file
    local exit_status=0
    find "$prefs_backup_dir" -name "*.plist" | while read -r plist_file; do
        local domain=$(basename "$plist_file" .plist)
        if ! defaults import "$domain" "$plist_file"; then
            echo "Error: Failed to restore preferences for $domain"
            exit_status=1
        fi
    done
    
    return $exit_status
}

backup_dotfiles() {
    local prefs_backup_dir="$1"
    
    # Use pipe instead of process substitution
    find "$prefs_backup_dir" -name "*.plist" | while read -r plist_file; do
        # Process each plist file
        local relative_path="${plist_file#$prefs_backup_dir/}"
        local target_path="$HOME/Library/Preferences/$relative_path"
        
        if [[ -f "$target_path" ]]; then
            cp -p "$target_path" "$plist_file"
        fi
    done
} 