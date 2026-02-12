# Omaforge Quick Reference

## Installation

```bash
# One-line installer (downloads both repos)
eval "$(curl -fsSL https://raw.githubusercontent.com/pixincreate/omaforge/main/unix/setup)"

# Manual (macOS)
git clone https://github.com/pixincreate/dotfiles.git ~/.dotfiles
git clone https://github.com/pixincreate/omaforge.git ~/.omaforge
cd ~/.omaforge/unix/macos
./macos-setup

# Manual (Fedora)
git clone https://github.com/pixincreate/dotfiles.git ~/.dotfiles
git clone https://github.com/pixincreate/omaforge.git ~/.omaforge
cd ~/.omaforge/unix/fedora
./fedora-setup
```

## Running Individual Components

Both macOS and Fedora support running specific modules:

```bash
# Syntax
./macos-setup --only <module-path>    # macOS
./fedora-setup --only <module-path>   # Fedora

# Examples
--only dotfiles/stow         # Stow all dotfiles
--only dotfiles/zsh          # Reconfigure ZSH only
--only config/git            # Reconfigure Git only
--only config/nextdns        # Reconfigure NextDNS only
```

### macOS Modules

```bash
# Dotfiles
./macos-setup --only dotfiles/stow        # Stow all packages
./macos-setup --only dotfiles/zsh         # Configure ZSH
./macos-setup --only dotfiles/fonts       # Install fonts
./macos-setup --only dotfiles/directories # Create directories

# Packaging
./macos-setup --only packaging/homebrew   # Install Homebrew
./macos-setup --only packaging/brew       # Install brew packages
./macos-setup --only packaging/cask       # Install cask apps
./macos-setup --only packaging/rust       # Install rust tools

# Config
./macos-setup --only config/system        # System config
./macos-setup --only config/git           # Git & SSH
./macos-setup --only config/nextdns       # NextDNS
```

### Fedora Modules

```bash
# Dotfiles (same as macOS)
./fedora-setup --only dotfiles/stow
./fedora-setup --only dotfiles/zsh

# Packaging
./fedora-setup --only packaging/base      # Base packages
./fedora-setup --only packaging/flatpak   # Flatpak apps
./fedora-setup --only packaging/rust      # Rust tools

# Config
./fedora-setup --only config/git
./fedora-setup --only config/services     # Enable services
./fedora-setup --only config/performance  # Performance tuning
./fedora-setup --only config/hardware/asus    # ASUS laptop
./fedora-setup --only config/hardware/nvidia  # NVIDIA drivers

# Repositories
./fedora-setup --only repositories/all    # All repos
./fedora-setup --only repositories/rpmfusion
```

## Dotfiles Management

### Selective Stowing

```bash
# Stow all packages
omaforge-stow --all

# Stow specific packages
omaforge-stow config zsh          # Only config and zsh
omaforge-stow git                 # Only git

# Restow (useful after updates)
omaforge-stow -R config           # Restow config
omaforge-stow -R --all            # Restow all

# Unstow (remove symlinks)
omaforge-stow -d git              # Remove git symlinks

# Available packages
cargo, config, git, local, Pictures, ssh, zsh
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
./bin/omaforge-add rust bat          # Add Rust tool
./macos-setup --only packaging/brew  # Install new packages

# Fedora
./bin/omaforge-add base neovim       # Add to base packages
./bin/omaforge-add dev docker        # Add dev tool
./bin/omaforge-add tools steam       # Add user app
./bin/omaforge-add flatpak com.spotify.Client  # Add Flatpak
./fedora-setup --only packaging/base # Install new packages
```

### Interactive

```bash
./bin/omaforge-pkg-manage
```

Features: Add, remove, search packages with availability checking.

### Manual

```bash
# macOS
echo "neovim" >> packages/brew.packages
./macos-setup --only packaging/brew

# Fedora
echo "neovim" >> packages/base.packages
./fedora-setup --only packaging/base
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
./bin/omaforge-webapp-remove          # Interactive
./bin/omaforge-webapp-remove ChatGPT  # Specific app
```

## Directory Structure

```
~/.dotfiles/              # Dotfiles repository
├── home/                 # Stow packages
│   ├── config/          # App configs (~/.config/)
│   ├── zsh/             # ZSH config (~/.zsh/)
│   ├── git/             # Git config (~/.gitconfig)
│   ├── ssh/             # SSH config (~/.ssh/)
│   └── ...
└── fonts/               # Font files

~/.omaforge/              # Installer repository
├── unix/
│   ├── setup            # Main installer
│   ├── macos/           # macOS-specific
│   │   ├── macos-setup
│   │   ├── bin/         # Utilities
│   │   └── install/     # Install scripts
│   └── fedora/          # Fedora-specific
│       ├── fedora-setup
│       ├── bin/         # Utilities
│       └── install/     # Install scripts
└── windows/             # Windows tools
```

## Configuration Files

- `~/.omaforge/unix/macos/config.json` - macOS configuration
- `~/.omaforge/unix/fedora/config.json` - Fedora configuration
- `~/.dotfiles/home/` - Dotfile packages

## Tips

1. **Update dotfiles**: `omaforge-stow -R --all`
2. **Add package**: `omaforge-add <type> <package>` then run specific packaging module
3. **Fix specific component**: Use `--only` flag to re-run just that module
4. **Check what's installed**: Look at the `.packages` files in each platform's directory
5. **Custom configs**: Edit the `config.json` files before running setup
