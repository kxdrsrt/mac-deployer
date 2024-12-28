#!/bin/bash
# Test script for preferences

# Source required files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/preferences/utils.sh"

# Test functions
test_preference_files() {
    echo "Testing preference files..."
    local error=0
    
    for pref_file in "${SCRIPT_DIR}/preferences"/*.sh; do
        if ! bash -n "$pref_file"; then
            echo "Syntax error in $pref_file"
            error=1
        fi
    done
    
    return $error
}

test_settings_format() {
    echo "Testing settings format..."
    local error=0
    
    source_preference_files
    
    # Test each settings array
    for var in $(compgen -A variable | grep _SETTINGS$); do
        local -n settings=$var
        for setting in "${settings[@]}"; do
            if [[ ! "$setting" =~ ^[^:]+:[^:]+:(bool|int|float|string)?$ ]]; then
                echo "Invalid setting format in $var: $setting"
                error=1
            fi
        done
    done
    
    return $error
}

# Run tests
main() {
    local error=0
    
    test_preference_files || error=1
    test_settings_format || error=1
    
    if ((error)); then
        echo "Tests failed"
        exit 1
    else
        echo "All tests passed"
    fi
}

main 