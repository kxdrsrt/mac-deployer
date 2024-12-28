#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Utility functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_colored() {
    printf "%b%s%b\n" "$1" "$2" "$NC"
}

log_message() {
    echo "$@" | tee -a "$LOG_FILE"
}

# Add check_macos_version function
check_macos_version() {
    local current_version=$(sw_vers -productVersion)
    if [[ "$(printf '%s\n' "$MIN_MACOS_VERSION" "$current_version" | sort -V | head -n1)" != "$MIN_MACOS_VERSION" ]]; then
        printf "%bError: This script requires macOS %s or later%b\n" "$RED" "$MIN_MACOS_VERSION" "$NC"
        printf "%bCurrent version: %s%b\n" "$RED" "$current_version" "$NC"
        return 1
    fi
    return 0
}

check_homebrew() {
    if ! command_exists brew; then
        printf "Installing Homebrew...\n"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    return 0
}

install_or_upgrade_brew_packages() {
    printf "Installing/upgrading Homebrew packages...\n"
    for package in "${PACKAGES[@]}"; do
        if brew list --formula | grep -q "^$package\$"; then
            brew upgrade "$package" || return 1
        else
            brew install "$package" || return 1
        fi
    done
    return 0
}

install_or_upgrade_brew_casks() {
    printf "Installing/upgrading Homebrew casks...\n"
    for cask in "${CASKS[@]}"; do
        if [[ $cask =~ ^#.* ]]; then
            continue
        fi
        if brew list --cask | grep -q "^$cask\$"; then
            brew upgrade --cask "$cask" || return 1
        else
            brew install --cask "$cask" || return 1
        fi
    done
    return 0
}

install_or_upgrade_mas_apps() {
    printf "Installing/upgrading Mac App Store apps...\n"
    if ! command_exists mas; then
        printf "Installing mas-cli...\n"
        brew install mas || return 1
    fi
    
    for app_id in "${MAS_APPS[@]}"; do
        if [[ $app_id =~ ^#.* ]]; then
            continue
        fi
        if mas list | grep -q "^$app_id"; then
            mas upgrade "$app_id" || return 1
        else
            mas install "$app_id" || return 1
        fi
    done
    return 0
} 