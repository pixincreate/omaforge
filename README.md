# Omaforge

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

## Supported Platforms

- **Fedora** - Fedora Linux with DNF, Flatpak, hardware support
- **macOS** - macOS with Homebrew

## Manual Installation

### Fedora

```bash
git clone https://github.com/pixincreate/dotfiles.git ~/dev/.dotfiles
git clone https://github.com/pixincreate/omaforge.git ~/dev/.omaforge
cd ~/dev/.omaforge/unix/fedora
./fedora-setup
```

### macOS

```bash
git clone https://github.com/pixincreate/dotfiles.git ~/dev/.dotfiles
git clone https://github.com/pixincreate/omaforge.git ~/dev/.omaforge
cd ~/dev/.omaforge/unix/macos
./macos-setup
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

## Utilities

### Fedora

- `omaforge-pkg-manage` - Interactive package manager
- `omaforge-webapp-install` - Install web applications
- `omaforge-webapp-remove` - Remove web applications
- `omaforge-launch-browser` - Launch browser (supports Zen, Brave, Helium)
- `omaforge-launch-webapp` - Launch web app in app mode
- `omaforge-reset` - Reset/re-run specific components

### macOS

- `omaforge-pkg-manage` - Interactive package manager
- `omaforge-reset` - Reset/re-run specific components

## Configuration

Each platform has a `config.json` for declarative configuration. See platform-specific READMEs for details.

## Documentation

- **[Fedora Setup Guide](unix/fedora/README.md)** - Fedora-specific documentation
- **[macOS Setup Guide](unix/macos/README.md)** - macOS-specific documentation

## License

GPL 3.0 License
