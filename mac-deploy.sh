#!/bin/bash

###############################################################################
# Mac Deployment Script                                                         #
###############################################################################

# Script initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="1.0.0"
MIN_MACOS_VERSION="10.15"
MIN_DISK_SPACE_GB=10
MAX_PASSWORD_ATTEMPTS=3
SPOTIFY_PATH="/Applications/Spotify.app"

# Global variables
SUDO_PASSWORD=""
USE_STORED_PASSWORD=false
APPLY_SPOTX=false
temp_dir=""

if [[ -z "${LOG_FILE:-}" ]]; then
    LOG_FILE="$HOME/mac-deployer/deploy.log"
fi

# Function definitions
print_colored() {
    printf "%b%s%b\n" "$1" "$2" "$NC"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_header() {
    clear
    printf "%b" "$BLUE"
    printf "
 __  __            ____             _                       
|  \/  | __ _  ___|  _ \  ___ _ __ | | ___  _   _  ___ _ __ 
| |\/| |/ _\` |/ __| | | |/ _ \ '_ \| |/ _ \| | | |/ _ \ '__|
| |  | | (_| | (__| |_| |  __/ |_) | | (_) | |_| |  __/ |   
|_|  |_|\__,_|\___|____/ \___| .__/|_|\___/ \__, |\___|_|   
                             |_|            |___/           
"
    printf "╔═══════════════════════════════════════════════╗\n"
    printf "║           Mac Deployment Script               ║\n"
    printf "║                v%s                            ║\n" "$VERSION"
    printf "╚═══════════════════════════════════════════════╝\n"
    printf "%b" "$NC"
}

# Password handling functions
ask_for_password_preference() {
    printf "\n%bPassword Handling%b\n" "$BLUE" "$NC"
    printf "Would you like to store your password temporarily for automated installations?\n"
    printf "%bNote: Password will be stored in memory only and cleared on exit%b\n" "$YELLOW" "$NC"
    read -p "Store password? (y/n): " password_choice
    
    if [[ $password_choice =~ ^[Yy]$ ]]; then
        get_and_verify_password
        USE_STORED_PASSWORD=true
    fi
}

get_and_verify_password() {
    local attempts=0
    while [[ $attempts -lt $MAX_PASSWORD_ATTEMPTS ]]; do
        printf "\nPlease enter your macOS password:\n"
        read -s SUDO_PASSWORD
        printf "\n"
        
        # Verify password
        if echo "$SUDO_PASSWORD" | sudo -S true 2>/dev/null; then
            printf "%bPassword verified successfully%b\n" "$GREEN" "$NC"
            return 0
        else
            printf "%bInvalid password%b\n" "$RED" "$NC"
            ((attempts++))
            
            if [[ $attempts -lt $MAX_PASSWORD_ATTEMPTS ]]; then
                printf "Please try again (%d attempts remaining)\n" "$((MAX_PASSWORD_ATTEMPTS - attempts))"
            fi
        fi
    done
    
    printf "%bMaximum password attempts exceeded%b\n" "$RED" "$NC"
    USE_STORED_PASSWORD=false
    SUDO_PASSWORD=""
    return 1
}

# Deployment functions
do_full_deployment() {
    printf "Starting full deployment...\n"
    
    # Backup existing configurations
    if ! backup_configs; then
        printf "%bBackup failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    # Install/update applications
    if ! do_apps_only; then
        printf "%bApplication installation failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    # Configure preferences
    if ! do_preferences_only; then
        printf "%bPreference configuration failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    # Apply SpotX if selected
    if [[ "$APPLY_SPOTX" == "true" ]]; then
        if ! apply_spotx_patch; then
            printf "%bSpotX patch failed%b\n" "$RED" "$NC"
            return 1
        fi
    fi
    
    printf "%bFull deployment completed successfully%b\n" "$GREEN" "$NC"
    return 0
}

do_apps_only() {
    printf "Installing applications...\n"
    
    # Check and install Homebrew
    if ! check_homebrew; then
        printf "%bHomebrew setup failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    # Install/upgrade packages
    if ! install_or_upgrade_brew_packages; then
        printf "%bPackage installation failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    # Install/upgrade casks
    if ! install_or_upgrade_brew_casks; then
        printf "%bCask installation failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    # Install/upgrade Mac App Store apps
    if ! install_or_upgrade_mas_apps; then
        printf "%bApp Store installation failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    printf "%bApplication installation completed successfully%b\n" "$GREEN" "$NC"
    return 0
}

do_preferences_only() {
    printf "Configuring system preferences...\n"
    
    # Backup existing configurations
    if ! backup_configs; then
        printf "%bBackup failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    # Configure Mac preferences
    if ! configure_mac_prefs; then
        printf "%bPreference configuration failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    printf "%bPreference configuration completed successfully%b\n" "$GREEN" "$NC"
    return 0
}

do_animations_only() {
    printf "Configuring animation settings...\n"
    
    if ! configure_animation_prefs; then
        printf "%bAnimation configuration failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    printf "%bAnimation settings configured successfully%b\n" "$GREEN" "$NC"
    return 0
}

do_backup_only() {
    printf "Creating backup...\n"
    
    if ! backup_configs; then
        printf "%bBackup failed%b\n" "$RED" "$NC"
        return 1
    fi
    
    printf "%bBackup completed successfully%b\n" "$GREEN" "$NC"
    return 0
}

# Configuration loading
load_configurations() {
    # Load utils first for color variables
    source "${SCRIPT_DIR}/lib/utils.sh" || {
        echo "Error: Failed to load utils"
        exit 1
    }
    
    # Load adjust.sh for constants
    source "${SCRIPT_DIR}/config/adjust.sh" || {
        printf "%bError: Failed to load constants%b\n" "$RED" "$NC"
        exit 1
    }
    
    # Define the configuration files in order of dependency
    local config_files=(
        "lib/prefs.sh"
        "lib/backup.sh"
        "lib/validate-config.sh"
        "lib/spotx.sh"
        "config/packages.sh"
        "config/casks.sh"
        "config/mas_apps.sh"
        "config/dotfiles.sh"
    )
    
    # Load each configuration file
    for config in "${config_files[@]}"; do
        local config_path="${SCRIPT_DIR}/${config}"
        if [[ ! -f "$config_path" ]]; then
            printf "%bError: Required configuration file missing: %s%b\n" "$RED" "$config" "$NC"
            exit 1
        fi
        
        if ! source "$config_path"; then
            printf "%bError: Failed to load configuration file: %s%b\n" "$RED" "$config" "$NC"
            exit 1
        fi
        printf "Loaded configuration: %s\n" "$config"
    done
}

# Setup logging
setup_logging() {
    # Create log directory if it doesn't exist
    if ! mkdir -p "$(dirname "$LOG_FILE")"; then
        printf "%bError: Failed to create log directory%b\n" "$RED" "$NC"
        exit 1
    fi
    
    # Clear previous log
    if ! > "$LOG_FILE"; then
        printf "%bError: Failed to initialize log file%b\n" "$RED" "$NC"
        exit 1
    fi
    
    # Log start information
    {
        echo "Log started at $(date)"
        echo "macOS Version: $(sw_vers -productVersion)"
        echo "Script Version: $VERSION"
    } | tee "$LOG_FILE"
}

# Main function
main() {
    # Check if running with sudo
    if [[ $EUID -eq 0 ]]; then
        printf "%bDo not run this script with sudo%b\n" "$RED" "$NC"
        exit 1
    fi
    
    # Ask for password preference
    ask_for_password_preference
    
    # Ask for SpotX preference
    ask_for_spotx_preference
    
    # Perform system checks
    check_system_requirements
    
    # Start menu system
    main_menu
}

# Cleanup function
cleanup() {
    local exit_status=$?
    printf "Cleaning up...\n"
    
    # Clear stored password
    if [[ -n "$SUDO_PASSWORD" ]]; then
        SUDO_PASSWORD=""
        printf "Cleared stored password\n"
    fi
    
    # Kill affected processes
    local processes=(
        "Dock"
        "Finder"
        "SystemUIServer"
    )
    
    for process in "${processes[@]}"; do
        if pgrep "$process" >/dev/null; then
            killall "$process" 2>/dev/null || true
            printf "Restarted %s\n" "$process"
        fi
    done
    
    # Clean up temporary files
    if [[ -d "$temp_dir" ]]; then
        rm -rf "$temp_dir"
        printf "Removed temporary directory\n"
    fi
    
    printf "Cleanup completed with status %d\n" "$exit_status"
    exit $exit_status
}

# Error handling function
handle_error() {
    local exit_code=$1
    local line_no=$2
    local bash_lineno=$3
    local last_command=$4
    local func_trace=$5
    
    printf "%bError on line %s: Command '%s' exited with status %d%b\n" \
        "$RED" "$line_no" "$last_command" "$exit_code" "$NC"
    printf "Function trace: %s\n" "$func_trace"
}

# Menu functions
print_menu() {
    printf "\n%bAvailable Options:%b\n" "$GREEN" "$NC"
    printf "1) Full Deployment (Apps + Preferences)\n"
    printf "2) Applications Only (Homebrew + App Store)\n"
    printf "3) System Preferences Only\n"
    printf "4) Zero Animation Settings Only\n"
    printf "5) Backup Current Configuration\n"
    printf "q) Quit\n\n"
    read -p "Select an option: " choice
}

execute_option() {
    case $1 in
        1)
            printf "\n%bStarting full deployment...%b\n" "$BLUE" "$NC"
            do_full_deployment
            ;;
        2)
            printf "\n%bInstalling applications...%b\n" "$BLUE" "$NC"
            do_apps_only
            ;;
        3)
            printf "\n%bConfiguring system preferences...%b\n" "$BLUE" "$NC"
            do_preferences_only
            ;;
        4)
            printf "\n%bApplying zero animation settings...%b\n" "$BLUE" "$NC"
            do_animations_only
            ;;
        5)
            printf "\n%bCreating backup...%b\n" "$BLUE" "$NC"
            do_backup_only
            ;;
        *)
            printf "\n%bInvalid option%b\n" "$RED" "$NC"
            return 1
            ;;
    esac
}

main_menu() {
    local choice
    while true; do
        print_header
        print_menu
        
        case $choice in
            1|2|3|4|5)
                if ! execute_option "$choice"; then
                    printf "\n%bOperation failed%b\n" "$RED" "$NC"
                else
                    printf "\n%bOperation completed successfully!%b\n" "$GREEN" "$NC"
                fi
                printf "Press any key to continue..."
                read -n 1
                ;;
            q|Q)
                printf "\n%bExiting...%b\n" "$GREEN" "$NC"
                exit 0
                ;;
            *)
                printf "\n%bInvalid option%b\n" "$RED" "$NC"
                sleep 1
                ;;
        esac
    done
}

# Main execution starts here
load_configurations
setup_logging
main "$@"

# Set error handling
set -e
trap 'handle_error $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]:-})' ERR
trap cleanup EXIT
