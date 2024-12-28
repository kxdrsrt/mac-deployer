#!/bin/bash
# Security preferences configuration

# Security settings
readonly SECURITY_SETTINGS=(
    "GKAutoRearm:false:bool"                               # Game Center auto sign-in
    "ScanIncomingNetworkVolumes:false:bool"                # Scan network volumes
    "DisableGatekeeper:true:bool"                          # Disable Gatekeeper
    "AllowAppleIDSwitching:true:bool"                      # Allow Apple ID switching
)

# Privacy settings
readonly PRIVACY_SETTINGS=(
    "AnalyticsEnabled:false:bool"                          # Analytics
    "AutomaticSubmitEnabled:false:bool"                    # Crash reports
    "AllowIdentifiedDevelopers:true:bool"                  # Allow identified devs
) 