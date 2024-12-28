#!/bin/bash
# Display preferences configuration

# Display settings
readonly DISPLAY_SETTINGS=(
    "DisplaySleepTimer:15:int"                             # Display sleep timer
    "AutoBrightness:false:bool"                            # Auto brightness
    "TrueTone:false:bool"                                  # True Tone
    "NightShiftEnabled:true:bool"                          # Night Shift
    "BlueReduction:0.5:float"                              # Night Shift intensity
)

# Screen saver settings
readonly SCREENSAVER_SETTINGS=(
    "idleTime:0:int"                                       # Start after (0 = never)
    "showClock:false:bool"                                 # Show clock
) 