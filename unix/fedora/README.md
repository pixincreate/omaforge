# omaforge - Fedora

Automated Fedora system setup.

## Quick Start

```bash
cd ~/dev/.omaforge/unix/fedora
./fedora-setup
```

## Configuration

Edit `config.json`:

```json
{
  "system": { "hostname": "fedora-laptop" },
  "git": {
    "user_name": "Your Name",
    "user_email": "your@email.com"
  },
  "rust": {
    "tools": ["bat", "eza", "ripgrep", "zoxide", "starship"]
  }
}
```

## Running Individual Components

You can run specific parts of the setup without running everything:

```bash
# Run specific module
./fedora-setup --only dotfiles/stow        # Restow all dotfiles
./fedora-setup --only dotfiles/zsh         # Reconfigure ZSH only
./fedora-setup --only packaging/base       # Install only base packages
./fedora-setup --only config/git           # Reconfigure Git only
./fedora-setup --only config/hardware/asus # ASUS hardware setup only

# See all available modules
find install -name "*.sh" | grep -v all.sh
```

## Package Management

### Interactive

```bash
./bin/omaforge-pkg-manage
```

Add, remove, search packages with availability checking.

### Declarative (Recommended)

Add packages to lists and install:

```bash
# Add a package declaratively
./bin/omaforge-add base fastfetch          # Add to base.packages
./bin/omaforge-add dev neovim              # Add to development.packages
./bin/omaforge-add tools telegram-desktop  # Add to tools.packages
./bin/omaforge-add flatpak com.spotify.Client  # Add to flatpak.packages
./bin/omaforge-add rust exa                # Add to rust.packages

# Install only new packages
./fedora-setup --only packaging/base
./fedora-setup --only packaging/flatpak
```

### Manual

```bash
echo "fastfetch" >> packages/base.packages
./fedora-setup --only packaging/base
```

### Package Lists

- `base.packages` - Core utilities
- `development.packages` - Dev tools
- `tools.packages` - User applications
- `system.packages` - System libraries
- `flatpak.packages` - Flatpak apps
- `rust.packages` - Rust tools

## Web Applications

Installed by default:

- **Twitter (X)** - Standard
- **ChatGPT** - Incognito mode
- **Grok** - Incognito mode

### Install Custom

```bash
./bin/omaforge-webapp-install "App Name" "https://example.com" "https://example.com/icon.png"

# Incognito mode
./bin/omaforge-webapp-install "App" "https://example.com" "icon.png" \
  "omaforge-launch-browser --private https://example.com/"
```

### Remove

```bash
./bin/omaforge-webapp-remove           # Interactive
./bin/omaforgeomaforge-webapp-remove ChatGPT   # Specific
./bin/omaforgeomaforge-webapp-remove all       # All
```

## Dotfiles Management

Manage your dotfiles selectively:

```bash
# Stow all packages
./bin/omaforge-stow --all

# Stow specific packages
./bin/omaforge-stow config zsh     # Only config and zsh
./bin/omaforge-stow git            # Only git

# Restow (unstow then stow again) - useful for updates
./bin/omaforge-stow -R config      # Restow config
./bin/omaforge-stow -R --all       # Restow all

# Unstow (remove symlinks)
./bin/omaforge-stow -d git         # Unstow git
```

Available packages: `cargo`, `config`, `git`, `local`, `Pictures`, `ssh`, `zsh`

## What's Installed

- DNF optimization and system updates
- Repositories (RPM Fusion, COPR, Terra)
- Packages (DNF, Flatpak, Rust)
- Web apps (Twitter, ChatGPT, Grok)
- Hardware support (ASUS, NVIDIA)
- Performance tuning (zram, fstrim)
- Git/SSH, NextDNS, dotfiles, ZSH
- Services (PostgreSQL, Redis, Docker)

## Reset/Re-run Components

If you need to reset or re-run specific parts:

```bash
./bin/omaforge-reset
```

Interactive menu to reset:

- ZSH configuration
- Dotfiles (stow)
- Fonts
- Git & SSH
- NextDNS
- Services
- Hardware
- Web apps
- Rust tools

## Post-Install

1. Logout/login for group changes (docker, etc.)
2. Reboot if NVIDIA drivers were installed
3. Add SSH key to GitHub:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
4. Reload shell:
   ```bash
   exec zsh
   ```

## Troubleshooting

### Package install fails

```bash
dnf repolist
dnf makecache
```

### Git config issues

```bash
git config --list
ls -la ~/.ssh/
```

### Services don't start

```bash
systemctl status service-name
journalctl -u service-name
```

## Notes

- All scripts are idempotent (safe to re-run)
- Uses shared scripts from `unix/common/`
- See [main README](../../README.md) for overview
