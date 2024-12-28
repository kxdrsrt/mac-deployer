#!/bin/bash
# Keyboard preferences configuration

# Input Sources
readonly KEYBOARD_INPUT_SOURCES=(
    '<dict>
        <key>InputSourceKind</key>
        <string>Keyboard Layout</string>
        <key>KeyboardLayout ID</key>
        <integer>0</integer>
        <key>KeyboardLayout Name</key>
        <string>U.S.</string>
    </dict>'
    '<dict>
        <key>InputSourceKind</key>
        <string>Keyboard Layout</string>
        <key>KeyboardLayout ID</key>
        <integer>3</integer>
        <key>KeyboardLayout Name</key>
        <string>German</string>
    </dict>'
)

# Keyboard shortcuts
readonly KEYBOARD_SHORTCUTS=(
    # Format: "key:enabled:parameters:type"
    "AppleSymbolicHotKeys-52:true:100,2,1572864:standard"    # Launchpad
    "AppleSymbolicHotKeys-62:true:100,2,1179648:standard"    # Dock
    "AppleSymbolicHotKeys-28:false:51,20,1179648:standard"   # Screenshot
    "AppleSymbolicHotKeys-29:false:51,20,1441792:standard"   # Screenshot
    "AppleSymbolicHotKeys-30:false:52,21,1179648:standard"   # Screenshot
    "AppleSymbolicHotKeys-31:false:52,21,1441792:standard"   # Screenshot
    "AppleSymbolicHotKeys-184:false:53,23,1179648:standard"  # Screenshot
    "AppleSymbolicHotKeys-64:false:32,49,262144:standard"    # Spotlight
    "AppleSymbolicHotKeys-65:false:32,49,786432:standard"    # Spotlight
) 