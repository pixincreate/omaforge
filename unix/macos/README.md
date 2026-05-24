# rig - macOS

Automated macOS system setup.

## Quick Start

```bash
cd ~/dev/.rig/unix/macos
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
# Run specific module (use full path to avoid ambiguity)
./macos-setup --only dotfiles/stow        # Restow all dotfiles
./macos-setup --only dotfiles/zsh         # Reconfigure ZSH only
./macos-setup --only packaging/brew       # Install only brew packages
./macos-setup --only config/git           # Reconfigure Git only

# See all available modules
find install -name "*.sh" | grep -v all.sh
```

**Note**: Module names must be unambiguous. If multiple modules share the
same filename (e.g., `all.sh` in multiple directories), use the full path
to disambiguate. Using just the filename will show an error listing all
matches.

## Unified CLI

Use the `rig` dispatcher to run any command (available after Fedora setup;
macOS uses the scripts directly via `./bin/`):

```bash
rig stow --all              # Stow all dotfiles
rig add brew neovim         # Add a package declaratively
rig pkg-manage              # Interactive package manager
rig reset                   # Reset components
```

The dispatcher lives at `unix/fedora/bin/rig` and auto-discovers all
`rig-*` scripts. macOS scripts are standalone but use the same metadata
format and are compatible with the dispatcher when running on Fedora.

## Package Management

### Interactive

```bash
./bin/rig-pkg-manage
# or: rig pkg-manage (on Fedora)
```

Add, remove, search packages with availability checking.

### Declarative (Recommended)

Add packages to lists and install:

```bash
# Add a package declaratively
./bin/rig-add brew fastfetch      # Add to brew.packages
# or: rig add brew fastfetch (on Fedora)
./bin/rig-add cask firefox        # Add to cask.packages
./bin/rig-add rust exa            # Add to rust.packages

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
./bin/rig-stow --all
# or: rig stow --all (on Fedora)

# Stow specific packages
./bin/rig-stow config zsh     # Only config and zsh
./bin/rig-stow git            # Only git

# Restow (unstow then stow again) - useful for updates
./bin/rig-stow -R config      # Restow config
./bin/rig-stow -R --all       # Restow all

# Unstow (remove symlinks)
./bin/rig-stow -d git         # Unstow git
# or: rig stow -d git (on Fedora)
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
./bin/rig-reset
# or: rig reset (on Fedora)
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
