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
# Run specific module (use full path to avoid ambiguity)
./fedora-setup --only dotfiles/stow        # Restow all dotfiles
./fedora-setup --only dotfiles/zsh         # Reconfigure ZSH only
./fedora-setup --only dotfiles/ghostty     # Setup Ghostty terminal
./fedora-setup --only packaging/base       # Install only base packages
./fedora-setup --only config/git           # Reconfigure Git only
./fedora-setup --only config/hardware/asus # ASUS hardware setup only

# See all available modules
find install -name "*.sh" | grep -v all.sh
```

**Note**: Module names must be unambiguous. If multiple modules share the same
filename (e.g., `all.sh` in multiple directories), use the full path to
disambiguate. Using just the filename will show an error listing all matches.

## Unified CLI

Use the `omaforge` dispatcher to run any command:

```bash
omaforge                         # List all commands with descriptions
omaforge add base fastfetch      # Add a package declaratively
omaforge pkg-manage              # Interactive package manager
omaforge stow --all              # Stow all dotfiles
omaforge webapp-install "App" "https://..." "icon.png"
```

The dispatcher automatically discovers all `omaforge-*` scripts and reads their
metadata headers. Running `omaforge` with no arguments shows every available
command with its description and usage.

## Package Management

### Interactive

```bash
omaforge pkg-manage
# or: ./bin/omaforge-pkg-manage
```

Add, remove, search packages with availability checking.

### Declarative (Recommended)

Add packages to lists and install:

```bash
# Add a package declaratively
omaforge add base fastfetch          # Add to base.packages
omaforge add dev neovim              # Add to development.packages
omaforge add tools telegram-desktop  # Add to tools.packages
omaforge add flatpak com.spotify.Client  # Add to flatpak.packages
omaforge add rust exa                # Add to rust.packages
# or: ./bin/omaforge-add base fastfetch

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
omaforge webapp-install "App Name" "https://example.com" "https://example.com/icon.png"
# or: ./bin/omaforge-webapp-install "App Name" "https://..." "icon.png"

# Incognito mode
omaforge webapp-install "App" "https://example.com" "icon.png" \
  "omaforge-launch-browser --private https://example.com/"
```

### Remove

```bash
omaforge webapp-remove           # Interactive
omaforge webapp-remove ChatGPT   # Specific
omaforge webapp-remove all       # All
# or: ./bin/omaforge-webapp-remove ChatGPT
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

# Or use the unified dispatcher:
omaforge stow --all
omaforge stow config zsh
omaforge stow -R --all
omaforge stow -d git
```

Available packages: `cargo`, `config`, `git`, `local`, `Pictures`, `ssh`, `zsh`

### KDE Config Symlinks

KDE Plasma configuration files are symlinked from the repo to `~/.config/`
via `install/config/kde.sh` (run as part of `fedora-setup`):

```bash
./fedora-setup --only config/kde
```

Symlinked config files (backed up if regular files existed):

- `~/.config/kwinrc` — KWin window manager settings
- `~/.config/kwinrulesrc` — KWin window rules
- `~/.config/kdeglobals` — Global KDE settings
- `~/.config/kglobalshortcutsrc` — Global keyboard shortcuts
- `~/.config/plasmaparc` — Plasma panel/applet config

## What's Installed

- DNF optimization and system updates
- Repositories (RPM Fusion, COPR, Terra)
- Packages (DNF, Flatpak, Rust)
- Web apps (Twitter, ChatGPT, Grok)
- Hardware support (ASUS, NVIDIA)
- Performance tuning (zram, fstrim)
- Git/SSH, NextDNS, dotfiles, ZSH
- Services (PostgreSQL, Redis, Docker)
- Ghostty terminal with themes from iTerm2-Color-Schemes

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

## Hibernation Setup

The system configures zram swap by default (24GB). To enable hibernation:

1. Create swapfile equal to RAM size:

   ```bash
   sudo fallocate -l 24G /swapfile
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

2. Add to `/etc/fstab`:

   ```text
   /swapfile none swap defaults 0 0
   ```

3. Configure resume kernel parameter:

   ```bash
   SWAP_UUID=$(findmnt -no UUID -T /swapfile)
   SWAP_OFFSET=$(sudo filefrag -v /swapfile | \
     awk 'NR==4{print $4}' | tr -d '.')
   sudo grubby --update-kernel=ALL \
     --args="resume=UUID=$SWAP_UUID resume_offset=$SWAP_OFFSET"
   ```

4. Rebuild initramfs and reboot:

   ```bash
   sudo dracut -f
   sudo reboot
   ```

**Note**: systemd ignores zram for hibernate and uses the swapfile instead.
zram remains active for general swap use.

## Notes

- All scripts are idempotent (safe to re-run)
- Uses shared scripts from `unix/common/`
- See [main README](../../README.md) for overview
