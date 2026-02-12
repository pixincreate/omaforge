# omaforge - macOS

Automated macOS system setup.

## Quick Start

```bash
cd ~/dev/.omaforge/unix/macos
./macos-setup
```

## Configuration

Edit `config.json`:

```json
{
  "system": { "hostname": "pixmac" },
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
./macos-setup --only dotfiles/stow        # Restow all dotfiles
./macos-setup --only dotfiles/zsh         # Reconfigure ZSH only
./macos-setup --only packaging/brew       # Install only brew packages
./macos-setup --only config/git           # Reconfigure Git only

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
./bin/omaforge-add brew fastfetch      # Add to brew.packages
./bin/omaforge-add cask firefox        # Add to cask.packages
./bin/omaforge-add rust exa            # Add to rust.packages

# Install only new packages
./macos-setup --only packaging/brew
./macos-setup --only packaging/rust
```

### Manual

```bash
echo "fastfetch" >> packages/brew.packages
./macos-setup --only packaging/brew
```

### Package Lists

- `brew.packages` - CLI tools
- `cask.packages` - GUI applications
- `rust.packages` - Rust tools

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

- Homebrew setup
- Packages (Homebrew, Cask, Rust)
- System configuration (hostname)
- Git/SSH, NextDNS, dotfiles, ZSH

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
- Rust tools

## Post-Install

1. Add SSH key to GitHub:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
2. Reload shell:
   ```bash
   exec zsh
   ```

## Troubleshooting

### Homebrew issues

```bash
brew update
brew doctor
```

### Package install fails

```bash
brew search package-name
brew install package-name
```

## Notes

- All scripts are idempotent (safe to re-run)
- Uses shared scripts from `unix/common/`
- See [main README](../../README.md) for overview
