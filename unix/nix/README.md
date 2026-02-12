# Omaforge Nix Configuration

Minimal Nix + Home Manager setup for cross-platform package management.

## What This Does

- **Nix** manages packages (like brew/dnf but declarative)
- **Stow** manages dotfiles (unchanged from your existing setup)
- Works identically on macOS and Fedora

## Quick Start

### First Time Setup (macOS)

```bash
cd ~/dev/.omaforge/unix/nix
nix run home-manager -- switch --flake .#pix@pixmac
```

### First Time Setup (Fedora)

```bash
cd ~/dev/.omaforge/unix/nix
nix run home-manager -- switch --flake .#pix@pixfedora
```

### Daily Usage (After First Run)

```bash
# Add alias to your zshrc:
alias hm='home-manager switch --flake ~/dev/.omaforge/unix/nix#pix@pixmac'

# Then just:
hm
```

## Adding Packages

Edit `home.nix` and add to `home.packages`:

```nix
home.packages = with pkgs; [
  # existing packages...
  lazygit  # add this
];
```

Then run `hm` to apply.

## How It Works

1. `flake.nix` - Defines inputs (nixpkgs, home-manager) and outputs for both platforms
2. `home.nix` - Your user configuration: packages, shell integration, and stow activation
3. Home Manager automatically runs stow after activation to symlink dotfiles

## Files

- `flake.nix` - Main entry point
- `home.nix` - Package definitions and configuration
- `flake.lock` - Dependency lock file (auto-generated)

## Troubleshooting

- **Stow conflicts**: Run `stow -R --adopt` manually first, then `hm`
- **Package not found**: Check [nixpkgs search](https://search.nixos.org/packages)
- **Rollback**: `home-manager switch --rollback`

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Learn Nix gradually
