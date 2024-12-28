#!/bin/bash
# iCloud preferences configuration

# iCloud settings
readonly ICLOUD_SETTINGS=(
    "NSDocumentSaveNewDocumentsToCloud:true:bool"          # Save to iCloud by default
    "CloudDocs.Enabled:true:bool"                          # iCloud Drive
    "cloudDocs.desktop.Enabled:true:bool"                  # Desktop sync
    "cloudDocs.documents.Enabled:true:bool"                # Documents sync
    "OptimizeStorage:true:bool"                            # Optimize storage
)

# iCloud features
readonly ICLOUD_FEATURES=(
    "Photos:true"                                          # Photos
    "Drive:true"                                           # iCloud Drive
    "Mail:false"                                           # Mail
    "Calendar:true"                                        # Calendar
    "Contacts:true"                                        # Contacts
    "Reminders:true"                                       # Reminders
    "Notes:true"                                           # Notes
    "Keychain:true"                                        # Keychain
) 