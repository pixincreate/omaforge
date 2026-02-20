# Omaforge

```

 ▄██████▄    ▄▄▄▄███▄▄▄▄      ▄████████    ▄████████  ▄██████▄     ▄████████    ▄██████▄     ▄████████
███    ███ ▄██▀▀▀███▀▀▀██▄   ███    ███   ███    ███ ███    ███   ███    ███   ███    ███   ███    ███
███    ███ ███   ███   ███   ███    ███   ███    █▀  ███    ███   ███    ███   ███    █▀    ███    █▀
███    ███ ███   ███   ███   ███    ███  ▄███▄▄▄     ███    ███  ▄███▄▄▄▄██▀  ▄███         ▄███▄▄▄
███    ███ ███   ███   ███ ▀███████████ ▀▀███▀▀▀     ███    ███ ▀▀███▀▀▀▀▀   ▀▀███ ████▄  ▀▀███▀▀▀
███    ███ ███   ███   ███   ███    ███   ███        ███    ███ ▀███████████   ███    ███   ███    █▄
███    ███ ███   ███   ███   ███    ███   ███        ███    ███   ███    ███   ███    ███   ███    ███
 ▀██████▀   ▀█   ███   █▀    ███    █▀    ███         ▀██████▀    ███    ███   ████████▀    ██████████
                                                                   ███    ███

```

Automated system setup for Fedora Linux and macOS.

## Quick Start

### One-line Installer

```bash
eval "$(curl -fsSL https://raw.githubusercontent.com/pixincreate/omaforge/main/unix/setup)"
```

The installer automatically:

- Detect your platform (Fedora or macOS)
- Clone the dotfiles repository to `~/dev/.dotfiles`
- Clone this repository to `~/dev/.omaforge`
- Prompt you for Git name/email, NextDNS config, etc.
- Run the complete setup

**Optional**: Skip prompts by exporting environment variables:

```bash
export OMAFORGE_GIT_NAME='Your Name'
export OMAFORGE_GIT_EMAIL='your@email.com'
export OMAFORGE_NEXTDNS_ID='abc123'
export OMAFORGE_SECUREBOOT='true'  # Fedora only
eval "$(curl -fsSL https://raw.githubusercontent.com/pixincreate/omaforge/main/unix/setup)"
```

### Manual Installation

```bash
# macOS
git clone https://github.com/pixincreate/dotfiles.git ~/.dotfiles
git clone https://github.com/pixincreate/omaforge.git ~/.omaforge
cd ~/.omaforge/unix/macos
./macos-setup

# Fedora
git clone https://github.com/pixincreate/dotfiles.git ~/.dotfiles
git clone https://github.com/pixincreate/omaforge.git ~/.omaforge
cd ~/.omaforge/unix/fedora
./fedora-setup
```

## Running Individual Components

Both macOS and Fedora support running specific modules:

```bash
./macos-setup --only <module-path>    # macOS
./fedora-setup --only <module-path>   # Fedora
```

### macOS Modules

```bash
./macos-setup --only dotfiles/stow        # Stow all packages
./macos-setup --only dotfiles/zsh         # Configure ZSH
./macos-setup --only dotfiles/fonts       # Install fonts
./macos-setup --only packaging/homebrew   # Install Homebrew
./macos-setup --only packaging/brew       # Install brew packages
./macos-setup --only packaging/cask       # Install cask apps
./macos-setup --only config/git           # Git & SSH
./macos-setup --only config/nextdns       # NextDNS
```

### Fedora Modules

```bash
./fedora-setup --only dotfiles/stow
./fedora-setup --only dotfiles/zsh
./fedora-setup --only packaging/base      # Base packages
./fedora-setup --only packaging/flatpak   # Flatpak apps
./fedora-setup --only packaging/rust      # Rust tools
./fedora-setup --only config/git
./fedora-setup --only config/services     # Enable services
./fedora-setup --only config/performance  # Performance tuning
./fedora-setup --only config/hardware/asus    # ASUS laptop
./fedora-setup --only config/hardware/nvidia  # NVIDIA drivers
```

## Dotfiles Management

### Selective Stowing

```bash
# Stow all packages
omaforge-stow --all

# Stow specific packages
omaforge-stow config zsh          # Only config and zsh

# Restow (useful after updates)
omaforge-stow -R config           # Restow config
omaforge-stow -R --all            # Restow all
```

### Manual Stow

```bash
cd ~/.dotfiles
stow --no-folding --restow --target=$HOME home/config
stow --no-folding --restow --target=$HOME home/zsh
```

## Package Management

### Declarative (Recommended)

```bash
# macOS
./bin/omaforge-add brew neovim       # Add CLI tool
./bin/omaforge-add cask firefox      # Add GUI app
./macos-setup --only packaging/brew  # Install new packages

# Fedora
./bin/omaforge-add base neovim       # Add to base packages
./bin/omaforge-add flatpak com.spotify.Client  # Add Flatpak
./fedora-setup --only packaging/base # Install new packages
```

### Interactive

```bash
./bin/omaforge-pkg-manage
```

## Reset/Re-run Components

```bash
./bin/omaforge-reset
```

Interactive menu to reset specific components.

## Web Applications (Fedora only)

```bash
# Install
./bin/omaforge-webapp-install "App Name" "https://example.com" "icon.png"

# Remove
./bin/omaforge-webapp-remove ChatGPT  # Specific app
```

## Structure

```
.
├── unix/
│   ├── setup              # Common entry point (OS detection)
│   ├── common/            # Cross-platform scripts
│   ├── fedora/            # Fedora-specific setup
│   └── macos/             # macOS-specific setup
├── windows/               # Windows configuration (see windows/README.md)
└── docs/                  # Documentation
```

## Features

### Common (Both Platforms)

- **Git & SSH**: ed25519 keys with automatic configuration
- **Shell**: ZSH with zgenom plugin manager
- **Dotfiles**: GNU Stow for symlink management
- **Fonts**: Nerd Fonts and custom fonts
- **Rust**: Rustup with configurable cargo tools
- **NextDNS**: Automated DNS configuration

### Fedora-Specific

- **Package Management**: DNF optimization, Flatpak, Rust tools
- **Repositories**: RPM Fusion, COPR, Terra
- **Web Applications**: Twitter, ChatGPT (incognito), Grok (incognito)
- **Hardware Support**: ASUS laptops, NVIDIA drivers
- **Performance**: zram, fstrim, systemd-oomd
- **Services**: PostgreSQL, Redis, Docker
- **Security**: Firmware updates, Secure Boot

### macOS-Specific

- **Package Management**: Homebrew, Cask, Rust tools
- **Applications**: CLI tools and GUI applications
- **System**: Hostname and system preferences

## Configuration

Each platform has a `config.json` for declarative configuration:

- `unix/macos/config.json` - macOS configuration
- `unix/fedora/config.json` - Fedora configuration

## Documentation

- **[Fedora Setup Guide](unix/fedora/README.md)** - Fedora-specific documentation
- **[macOS Setup Guide](unix/macos/README.md)** - macOS-specific documentation

## License

CC0 1.0 Universal
