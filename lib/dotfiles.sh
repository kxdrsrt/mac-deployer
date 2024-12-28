#!/bin/bash

###############################################################################
# Dotfiles Management Functions                                                 #
###############################################################################

setup_dotfiles() {
    echo "Setting up dotfiles..."
    
    # Source configuration
    source "${SCRIPT_DIR}/config/dotfiles.sh"
    
    # Validate configuration
    validate_dotfiles_config || {
        echo "Error: Dotfiles configuration validation failed"
        return 1
    }
    
    # Create backup directory
    mkdir -p "$DOTFILES_BACKUP_DIR/$BACKUP_TIMESTAMP"
    
    # Clone or update repository
    if [[ -d "$DOTFILES_DIR" ]]; then
        echo "Updating dotfiles repository..."
        (cd "$DOTFILES_DIR" && git pull origin "$DOTFILES_BRANCH")
    else
        echo "Cloning dotfiles repository..."
        git clone -b "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi
    
    # Create required directories
    for dir in "${REQUIRED_DIRS[@]}"; do
        mkdir -p "$dir"
    done
    
    # Process template files
    for template_mapping in "${TEMPLATE_FILES[@]}"; do
        IFS=':' read -r template target processor <<< "$template_mapping"
        if [[ -f "$DOTFILES_DIR/$template" ]]; then
            echo "Processing template: $template"
            mkdir -p "$(dirname "$HOME/$target")"
            $processor "$DOTFILES_DIR/$template" "$HOME/$target"
        fi
    done
    
    # Create symlinks
    for mapping in "${DOTFILES[@]}"; do
        IFS=':' read -r source target <<< "$mapping"
        local source_path="$DOTFILES_DIR/$source"
        local target_path="$HOME/$target"
        
        # Backup existing file/directory
        if [[ -e "$target_path" ]]; then
            echo "Backing up: $target_path"
            cp -R "$target_path" "$DOTFILES_BACKUP_DIR/$BACKUP_TIMESTAMP/"
        fi
        
        # Create symlink
        echo "Linking: $source → $target"
        mkdir -p "$(dirname "$target_path")"
        ln -sf "$source_path" "$target_path"
    done
    
    # Copy files that shouldn't be symlinked
    for file in "${COPY_FILES[@]}"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            echo "Copying: $file"
            cp "$DOTFILES_DIR/$file" "$HOME/$file"
        fi
    done
    
    # Run post-installation commands
    for cmd_mapping in "${POST_INSTALL_COMMANDS[@]}"; do
        IFS=':' read -r description command <<< "$cmd_mapping"
        echo "Running: $description"
        eval "$command"
    done
    
    echo "Dotfiles setup complete"
}

restore_dotfiles_backup() {
    local backup_dir="$1"
    
    if [[ ! -d "$backup_dir" ]]; then
        echo "Error: Backup directory not found: $backup_dir"
        return 1
    fi
    
    echo "Restoring dotfiles from backup: $backup_dir"
    cp -R "$backup_dir/"* "$HOME/"
    echo "Dotfiles restored successfully"
} 