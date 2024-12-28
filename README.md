# Mac Deployer

A streamlined macOS setup and configuration automation tool. This script helps you quickly deploy a new Mac with your preferred applications and settings.

- [Mac Deployer](#mac-deployer)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Project Structure](#project-structure)
  - [Configuration](#configuration)
    - [Applications](#applications)
    - [System Preferences](#system-preferences)
    - [SpotX Configuration](#spotx-configuration)
  - [Logging](#logging)
  - [Contributing](#contributing)
  - [License](#license)

## Features

- 🚀 Full system deployment (apps + preferences)
- 📦 Application installation via Homebrew and Mac App Store
- ⚙️ System preferences configuration
- 🎯 Zero animation settings for performance
- 💾 Backup current configuration
- 🎵 Optional Spotify modification with SpotX

## Requirements

- macOS 10.15 (Catalina) or later
- Internet connection
- Administrator privileges

## Installation

1. Clone the repository:
```bash
git clone https://github.com/kxdrsrt/mac-deployer.git
cd mac-deployer
```

2. Make the script executable:
```bash
chmod +x mac-deploy.sh
```

## Usage

Run the script:
```bash
./mac-deploy.sh
```

The script will present a menu with the following options:
1. Full Deployment (Apps + Preferences)
2. Applications Only (Homebrew + App Store)
3. System Preferences Only
4. Zero Animation Settings Only
5. Backup Current Configuration

## Project Structure

```
.
├── mac-deploy.sh          # Main script
├── config/               # Configuration files
│   ├── adjust.sh        # Script constants and settings
│   ├── packages.sh      # Homebrew packages list
│   ├── casks.sh         # Homebrew casks list
│   ├── mas_apps.sh      # Mac App Store apps list
│   └── dotfiles.sh      # Dotfiles configuration
├── lib/                 # Library functions
│   ├── utils.sh         # Utility functions
│   ├── prefs.sh         # Preferences management
│   ├── backup.sh        # Backup functionality
│   ├── validate-config.sh # Configuration validation
│   └── spotx.sh         # Spotify modification
└── preferences/         # System preferences
    ├── animation.sh     # Animation settings
    ├── trackpad.sh      # Trackpad configuration
    └── utils.sh         # Preferences utilities
```

## Configuration

### Applications
Edit these files to customize installed applications:
- `config/packages.sh`: Homebrew packages
- `config/casks.sh`: Homebrew casks
- `config/mas_apps.sh`: Mac App Store applications

### System Preferences
Modify files in the `preferences/` directory:
- `animation.sh`: System animation settings
- `trackpad.sh`: Trackpad behavior

### SpotX Configuration
Adjust SpotX flags in `config/adjust.sh`:
- `B`: Block Spotify updates
- `c`: Clear Spotify cache
- `d`: Enable developer tools
- `h`: Hide non-music content

## Logging

Logs are stored in `~/mac-deployer/deploy.log` and include:
- Timestamp of operations
- Success/failure status
- Error messages
- System information

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
