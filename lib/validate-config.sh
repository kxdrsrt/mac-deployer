#!/bin/bash

###############################################################################
# Configuration Validation Functions                                            #
###############################################################################

validate_config() {
    echo "Validating configuration..."
    
    # Validate required directories exist
    local required_dirs=(
        "${SCRIPT_DIR}/config"
        "${SCRIPT_DIR}/lib"
        "${SCRIPT_DIR}/preferences"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo "Error: Required directory missing: $dir"
            return 1
        fi
    done
    
    # Validate required files exist
    local required_files=(
        "config/adjust.sh"
        "config/packages.sh"
        "config/casks.sh"
        "config/mas_apps.sh"
        "config/dotfiles.sh"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "${SCRIPT_DIR}/${file}" ]]; then
            echo "Error: Required file missing: $file"
            return 1
        fi
    done
    
    # Validate configuration values
    if ! validate_settings; then
        echo "Error: Invalid configuration settings"
        return 1
    fi
    
    echo "Configuration validation completed successfully"
    return 0
}

validate_settings() {
    local error=0
    
    # Validate numeric ranges
    if ! validate_numeric_range "$MOUSE_SPEED" 0 5 "Mouse speed"; then
        error=1
    fi
    
    if ! validate_numeric_range "$TRACKPAD_SPEED" 0 5 "Trackpad speed"; then
        error=1
    fi
    
    if ! validate_numeric_range "$DOCK_SIZE" 16 128 "Dock size"; then
        error=1
    fi
    
    # Validate paths
    if ! validate_directory "$(dirname "$SCREENSHOTS_DIR")" "Screenshots directory"; then
        error=1
    fi
    
    if ! validate_directory "$(dirname "$LOG_FILE")" "Log file directory"; then
        error=1
    fi
    
    # Validate URLs
    if ! validate_url "$DOTFILES_REPO" "Dotfiles repository"; then
        error=1
    fi
    
    return $error
}

validate_numeric_range() {
    local value=$1
    local min=$2
    local max=$3
    local name=$4
    
    if ! [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]] || 
       (( $(echo "$value < $min" | bc -l) )) || 
       (( $(echo "$value > $max" | bc -l) )); then
        echo "Error: $name must be between $min and $max"
        return 1
    fi
    return 0
}

validate_directory() {
    local dir=$1
    local name=$2
    
    if [[ ! -d "$dir" ]]; then
        echo "Error: Invalid $name path: $dir"
        return 1
    fi
    return 0
}

validate_url() {
    local url=$1
    local name=$2
    
    if [[ ! "$url" =~ ^https?:// ]]; then
        echo "Error: Invalid $name URL: $url"
        return 1
    fi
    return 0
}

# Validate package names
validate_packages() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Error: Homebrew not installed"
        return 1
    fi
    
    local invalid=0
    for package in "${PACKAGES[@]}"; do
        if ! brew info "$package" >/dev/null 2>&1; then
            echo "Warning: Package not found - $package"
            invalid=1
        fi
    done
    return $invalid
}

# Validate cask names
validate_casks() {
    if ! command -v brew >/dev/null 2>&1; then
        echo "Error: Homebrew not installed"
        return 1
    fi
    
    local invalid=0
    for cask in "${CASKS[@]}"; do
        if ! brew info --cask "$cask" >/dev/null 2>&1; then
            echo "Warning: Cask not found - $cask"
            invalid=1
        fi
    done
    return $invalid
}

# Validate Mac App Store IDs
validate_mas_apps() {
    if ! command -v mas >/dev/null 2>&1; then
        echo "Error: mas-cli not installed"
        return 1
    fi
    
    local invalid=0
    for app_id in "${MAS_APPS[@]}"; do
        if ! mas info "$app_id" >/dev/null 2>&1; then
            echo "Warning: App ID not found - $app_id"
            invalid=1
        fi
    done
    return $invalid
}

# Validate preference files
validate_preference_files() {
    local error=0
    for pref_file in "${SCRIPT_DIR}/preferences"/*.sh; do
        if [[ -f "$pref_file" ]]; then
            if ! bash -n "$pref_file"; then
                echo "Error in preference file: $pref_file"
                error=1
            fi
        fi
    done
    return $error
}

# Validate preference domains
validate_preferences() {
    local error=0
    
    # Validate preference domains exist
    if [[ -n "${PREFERENCE_DOMAINS+x}" ]]; then
        for domain in "${PREFERENCE_DOMAINS[@]}"; do
            if ! defaults read "$domain" >/dev/null 2>&1; then
                echo "Warning: Preference domain not found - $domain"
                error=1
            fi
        done
    fi
    
    # Validate preference files
    if [[ -n "${CONFIG_FILES+x}" ]]; then
        for config in "${CONFIG_FILES[@]}"; do
            local file
            IFS=':' read -r file _ <<< "$config"
            if [[ -f "${SCRIPT_DIR}/config/preferences/${file}" ]]; then
                if ! bash -n "${SCRIPT_DIR}/config/preferences/${file}"; then
                    echo "Error in preference file: ${file}"
                    error=1
                fi
            fi
        done
    fi
    
    return $error
}

# Run all validations
validate_all() {
    local status=0
    
    echo "Validating configuration..."
    validate_config || status=1
    validate_packages || status=1
    validate_casks || status=1
    validate_mas_apps || status=1
    validate_preference_files || status=1
    validate_preferences || status=1
    
    if [[ $status -eq 0 ]]; then
        echo "All validations passed successfully"
    else
        echo "Some validations failed"
    fi
    
    return $status
}

# Don't automatically run validation when sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_all
fi 