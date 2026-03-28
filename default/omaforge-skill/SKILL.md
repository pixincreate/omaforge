---
name: omaforge
description: >
  REQUIRED for contributing to omaforge installer development.
  Use when editing scripts in unix/fedora/, unix/macos/, unix/common/, or bin/.
  Triggers: installer scripts, package lists, config templates, helper functions,
  migration scripts, hardware detection, setup wizards. Excludes user config editing.
---

# Omaforge Skill

Development workflow for [omaforge](https://github.com/omaforge) - an opinionated system installer for Fedora Linux and macOS.

**This skill is for development contributions. For end-user customization, see omaforge-config skill.**

## When This Skill MUST Be Used

**ALWAYS invoke this skill for tasks involving ANY of these:**

- Editing shell scripts in `unix/fedora/`, `unix/macos/`, or `unix/common/`
- Modifying package lists in `packages/` directories
- Adding or editing `omaforge-*` bin commands
- Creating or modifying migration scripts in `migrations/`
- Changing installer phases (preflight, repositories, packaging, config, dotfiles, post-install)
- Updating helper functions (logging, common utilities)
- Working with configuration templates

**If you're about to edit a script in this repo, STOP and use this skill first.**

**Do NOT use this skill for**:
- Editing user `~/.config/` files on a running omaforge system
- Modifying omaforge's installed output (use omaforge-config skill instead)
- Tasks unrelated to omaforge development

## System Architecture

Omaforge supports both Fedora Linux and macOS with a shared codebase:

```
omaforge/
├── unix/
│   ├── common/              # Shared helpers (logging, common functions)
│   │   └── helpers/
│   ├── fedora/              # Fedora-specific installer
│   │   ├── bin/             # omaforge-* commands
│   │   ├── packages/        # Package lists (*.packages)
│   │   ├── config/          # Config templates
│   │   ├── dotfiles/        # User dotfiles
│   │   ├── migrations/      # Migration scripts
│   │   └── install/         # Installation phases
│   │       ├── helpers/     # Platform-specific helpers
│   │       ├── preflight/   # Guard checks, migrations
│   │       ├── repositories/# Package repos (COPR, brew)
│   │       ├── packaging/   # Package installation
│   │       ├── config/      # System configuration
│   │       ├── dotfiles/    # User dotfiles setup
│   │       └── post-install/# Final setup steps
│   └── macos/               # macOS-specific installer (same structure)
├── AGENTS.md                # Coding standards for AI
├── SKILL.md                 # This file
└── default/                 # Default configs (stowed to ~/.config/)
```

## Command Naming

All commands start with `omaforge-`. Prefixes indicate purpose:

- `cmd-` - check if commands exist, misc utility commands
- `pkg-` - package management helpers
- `hw-` - hardware detection (return exit codes for use in conditionals)
- `refresh-` - copy default config to user's `~/.config/`
- `restart-` - restart a component
- `launch-` - open applications
- `install-` - install optional software
- `setup-` - interactive setup wizards
- `toggle-` - toggle features on/off
- `theme-` - theme management
- `update-` - update components
- `dev-` - developer tools (not for end-users)

## Helper Commands

Use these instead of raw shell commands:

- `omaforge-cmd-missing` / `omaforge-cmd-present` - check for commands
- `omaforge-pkg-missing` / `omaforge-pkg-present` - check for packages
- `omaforge-pkg-add` - install packages (handles both Fedora and macOS)

## Code Style

See [AGENTS.md](./AGENTS.md) for full coding standards. Summary:

- **Indentation**: 2 spaces, no tabs
- **Shebangs**: `#!/bin/bash` (never `#!/usr/bin/env bash`)
- **Conditionals**: `[[ ]]` for strings/files, `(( ))` for numbers
- **Variables**: Don't quote in `[[ ]]`, do quote in commands
- **Commands**: Use `omaforge-cmd-*` helpers, not raw `command -v`

## Execution Model

```
fedora-setup / macos-setup
    ├── source helpers/all.sh          # Libraries use source
    ├── run_logged preflight/all.sh    # Work scripts use run_logged
    ├── run_logged repositories/all.sh
    ├── run_logged packaging/all.sh
    ├── run_logged config/all.sh
    ├── run_logged dotfiles/all.sh
    └── run_logged post-install/all.sh
```

**Key patterns**:
- `run_logged` executes scripts in subshells with logging
- Libraries (`helpers/all.sh`) use `source` to inject functions
- Work scripts can `return` at top level (subshell context)
- Error handler shows script name, line, and failing command

## Package Management

### Fedora
- Package manager: `dnf`
- Package lists: `unix/fedora/packages/*.packages`
- COPR repos: `unix/fedora/install/repositories/`
- Flatpak: `unix/fedora/packages/flatpak.packages`

### macOS
- Package manager: `brew`
- Package lists: `unix/macos/packages/brew.packages`
- Casks: `unix/macos/packages/casks.packages`

## Migrations

Migrations run during updates to modify existing installations:

- **Location**: `unix/{fedora,macos}/migrations/`
- **Naming**: Unix timestamp (e.g., `1760000000.sh`)
- **Format**: No shebang, start with echo description
- **Execution**: `run_logged` from preflight phase
- **State tracking**: `~/.local/state/omaforge/migrations/`

```bash
# Create new migration (use --no-edit to skip editor)
omaforge-dev-add-migration --no-edit
```

## Development Workflow

### Adding a New Package

1. Add to appropriate package list:
   ```bash
   echo "neovim" >> unix/fedora/packages/base.packages
   ```

2. Test installation:
   ```bash
   ./unix/fedora/fedora-setup --only packaging/base
   ```

### Adding a New Command

1. Create in `unix/{fedora,macos}/bin/`:
   ```bash
   #!/bin/bash
   # omaforge-<category>-<action> description

   set -euo pipefail
   # ... implementation
   ```

2. Make executable:
   ```bash
   chmod +x unix/fedora/bin/omaforge-<name>
   ```

3. Add to PATH in installer setup

### Adding Hardware Detection

1. Create script in `unix/{fedora,macos}/install/config/hardware/`
2. Check hardware in the script using `omaforge-hw-*` commands
3. Call from `hardware/all.sh` using `run_logged`

## Safe Patterns

### DO:
- ✅ Use `run_logged` for work scripts
- ✅ Use `omaforge-cmd-*` helpers for command checks
- ✅ Keep platform-specific code in platform directories
- ✅ Share common code in `unix/common/`
- ✅ Test with `--only` flag for specific phases

### DON'T:
- ❌ Never `source` work scripts (use `run_logged`)
- ❌ Never use `#!/usr/bin/env bash`
- ❌ Never use `local` outside functions
- ❌ Never hardcode paths (use `$OMAFORGE_*` variables)
- ❌ Never skip error handling in install scripts

## Troubleshooting

```bash
# Check syntax of a script
shellcheck -S error unix/fedora/bin/omaforge-*

# Run specific installer phase
./unix/fedora/fedora-setup --only packaging/all

# View installer logs
cat /var/log/omaforge-install.log

# Debug a command
bash -x unix/fedora/bin/omaforge-pkg-add test-pkg
```

## Decision Framework

When contributing changes:

1. **Is it shared between platforms?** Put in `unix/common/`
2. **Is it Fedora-specific?** Put in `unix/fedora/`
3. **Is it macOS-specific?** Put in `unix/macos/`
4. **Is it a command?** Add to `bin/` with proper naming
5. **Is it a migration?** Create with timestamp name in `migrations/`
6. **Is it a package?** Add to appropriate `*.packages` file

## Example Contributions

- "Add support for Rust toolchain" → Update `packages/rust.packages`, add install script
- "Fix ASUS audio issues" → Edit `install/config/hardware/asus.sh`
- "Add PostgreSQL package" → Add to `packages/development.packages`
- "Create new migration for config change" → `omaforge-dev-add-migration`

## Out of Scope

This skill does not cover:
- User configuration editing (use omaforge-config skill)
- Non-installer shell scripting
- System administration after installation
