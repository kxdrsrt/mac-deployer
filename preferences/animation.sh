#!/bin/bash

###############################################################################
# Animation Preferences Configuration                                           #
# This file contains settings to minimize or disable system animations         #
###############################################################################

# Stage Manager settings - Controls the behavior and timing of Stage Manager window management
readonly STAGE_MANAGER_SETTINGS=(
    "AutoHideDelay:-1.0:float"              # Delay before Stage Manager auto-hides (-1.0 disables auto-hide)
    "EnableStageManager:true:bool"           # Enable or disable Stage Manager functionality
    "StageManagerHideDelayTime:-1.0:float"  # Delay before Stage Manager hides windows (-1.0 disables delay)
    "StandardHideTimeout:0.0001:float"       # Standard hide animation duration (nearly instant)
    "HideTimeout:0.0001:float"              # General hide animation duration (nearly instant)
)

# Dock settings - Controls animation timing and behavior of the Dock
readonly DOCK_SETTINGS=(
    "autohide-delay:0.0001:float"           # Delay before Dock auto-hides (nearly instant)
    "autohide-time-modifier:0.0001:float"   # Speed modifier for Dock hide/show animation (nearly instant)
    "autohide:true:bool"                    # Enable Dock auto-hide feature
    "expose-animation-duration:0.1:float"    # Mission Control animation duration (very fast)
    "springboard-show-duration:0:int"        # Launchpad show animation duration (instant)
    "springboard-hide-duration:0:int"        # Launchpad hide animation duration (instant)
)

# Global animation settings - System-wide animation behaviors
readonly GLOBAL_SETTINGS=(
    "NSWindowResizeTime:0.001:float"                    # Window resize animation duration (nearly instant)
    "NSAutomaticWindowAnimationsEnabled:false:bool"     # Disable automatic window animations
    "QLPanelAnimationDuration:0:float"                  # Quick Look panel animation duration (instant)
) 