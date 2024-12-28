#!/bin/bash
# Sound preferences configuration

# Sound effect settings
readonly SOUND_SETTINGS=(
    "com.apple.sound.beep.sound:/System/Library/Sounds/Bubble.aiff:string"
    "com.apple.sound.beep.volume:0.6785:float"
    "com.apple.sound.uiaudio.enabled:true:bool"             # UI sound effects
    "com.apple.sound.beep.feedback:false:bool"              # Volume change feedback
    "com.apple.sound.beep.flash:false:bool"                 # Screen flash
    "com.apple.sound.startup.enabled:false:bool"            # Startup sound
)

# Output settings
readonly SOUND_OUTPUT_SETTINGS=(
    "output volume:50:int"                                  # System volume
    "Master Balance:0.5:float"                              # Balance
) 