#!/bin/bash

###############################################################################
# SpotX Installation Functions                                                  #
###############################################################################

# Check if Spotify is installed
check_spotify_installed() {
    if [[ ! -f "$SPOTIFY_PATH/Contents/MacOS/Spotify" ]]; then
        echo "Error: Spotify is not installed"
        return 1
    fi
    return 0
}

# Apply SpotX patch
apply_spotx_patch() {
    if [[ ! -f "$SPOTIFY_PATH/Contents/MacOS/Spotify" ]]; then
        printf "%bSpotify not installed%b\n" "$RED" "$NC"
        return 1
    fi
    
    printf "Applying SpotX patch...\n"
    
    # Download and run SpotX installer
    if ! curl -sL "https://raw.githubusercontent.com/SpotX-CLI/SpotX-Mac/main/install.sh" | sh -s -- "$SPOTX_FLAGS"; then
        printf "%bFailed to apply SpotX patch%b\n" "$RED" "$NC"
        return 1
    fi
    
    printf "%bSpotX patch applied successfully%b\n" "$GREEN" "$NC"
    return 0
}

# Ask for SpotX preference
ask_for_spotx_preference() {
    if [[ ! -f "$SPOTIFY_PATH/Contents/MacOS/Spotify" ]]; then
        printf "%bSpotify not installed. SpotX option will be disabled.%b\n" "$YELLOW" "$NC"
        APPLY_SPOTX=false
        return
    fi

    printf "\n%bSpotify Modification%b\n" "$BLUE" "$NC"
    printf "Would you like to patch Spotify with SpotX during deployment?\n"
    printf "%bNote: This will modify your Spotify installation with the following changes:%b\n" "$YELLOW" "$NC"
    [[ $SPOTX_FLAGS == *B* ]] && printf " • Block Spotify updates\n"
    [[ $SPOTX_FLAGS == *c* ]] && printf " • Clear Spotify cache\n"
    [[ $SPOTX_FLAGS == *d* ]] && printf " • Enable developer tools\n"
    [[ $SPOTX_FLAGS == *h* ]] && printf " • Hide non-music content (podcasts, etc.)\n"
    read -p "Apply SpotX patch? (y/n): " spotx_choice
    
    if [[ $spotx_choice =~ ^[Yy]$ ]]; then
        APPLY_SPOTX=true
    else
        APPLY_SPOTX=false
    fi
}

# Cleanup function for SpotX
cleanup_spotx() {
    if [[ -d "$HOME/.cache/spotx" ]]; then
        rm -rf "$HOME/.cache/spotx"
    fi
}

# Register cleanup function
trap cleanup_spotx EXIT 