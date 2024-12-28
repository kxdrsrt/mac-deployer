#!/bin/bash
# Finder preferences configuration

# Finder settings
readonly FINDER_SETTINGS=(
    "AppleShowAllFiles:true:bool"                            # Show hidden files
    "ShowPathbar:true:bool"                                  # Show path bar
    "_FXSortFoldersFirst:true:bool"                         # Keep folders on top
    "FXDefaultSearchScope:SCcf:string"                       # Search current folder
)

# Global Finder settings
readonly FINDER_GLOBAL_SETTINGS=(
    "AppleShowAllExtensions:true:bool"                       # Show file extensions
) 