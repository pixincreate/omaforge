---
name: rig
description: >
  REQUIRED for contributing to rig installer development.
  Use when editing scripts in unix/fedora/, unix/macos/, unix/common/, or bin/.
  Triggers: installer scripts, package lists, config templates, helper functions,
  migration scripts, hardware detection, setup wizards. Excludes user config editing.
---

# Rig Skill

Development workflow for [rig](https://github.com/rig) - an opinionated
system installer for Fedora Linux and macOS.

**This skill is for development contributions. For end-user customization,
see rig-config skill.**

## When This Skill MUST Be Used

**ALWAYS invoke this skill for tasks involving ANY of these:**

- Editing shell scripts in `unix/fedora/`, `unix/macos/`, or `unix/common/`
- Modifying package lists in `packages/` directories
- Adding or editing `rig-*` bin commands
- Creating or modifying migration scripts in `migrations/`
- Changing installer phases (preflight, repositories, packaging, config,
  dotfiles, post-install)
- Updating helper functions (logging, common utilities)
- Working with configuration templates

**If you're about to edit a script in this repo, STOP and use this skill first.**

**Do NOT use this skill for**:

- Editing user `~/.config/` files on a running rig system
- Modifying rig's installed output (use rig-config skill instead)
- Tasks unrelated to rig development

## System Architecture

Rig supports both Fedora Linux and macOS with a shared codebase:

```text
rig/
├── unix/
│   ├── common/              # Shared helpers (logging, common functions)
│   │   └── helpers/
│   ├── fedora/              # Fedora-specific installer
│   │   ├── bin/             # rig-* commands + rig dispatcher
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

### Unified CLI Dispatcher

The Fedora distribution includes a unified CLI dispatcher at
`unix/fedora/bin/rig` that discovers all `rig-*` scripts and provides
a single entry point:

```bash
rig                    # List all available commands with descriptions
rig stow --all         # Same as ./bin/rig-stow --all
rig add base neovim    # Same as ./bin/rig-add base neovim
```

The dispatcher reads `# rig:summary=` and `# rig:usage=` metadata
lines from each script. **Every new or edited bin script MUST include these
annotations** so the command appears in the help output.

```bash
# rig:summary=Short description of the command
# rig:usage=rig <cmd> [options] [args]
```

macOS scripts are standalone and do not use the dispatcher, but **must still
include the metadata headers** for consistency and cross-platform compatibility.

## Cross-Platform Mirroring

Rig has mirrored directory structures under `unix/fedora/` and
`unix/macos/`. **When you make changes to scripts, package lists, or
configuration that are not inherently platform-specific, you must mirror
the same change to the counterpart platform.**

Examples of changes that need mirroring:

- A new `rig-*` bin script added to Fedora → add the equivalent to macOS
- A new shared package added to Fedora package list → add to macOS equivalent
- A new install module that isn't hardware-specific → create on both platforms

Changes that are **platform-specific** (no mirroring needed):

- Fedora-only hardware support (ASUS, NVIDIA)
- macOS-only system configuration (hostname, defaults)
- Package managers (DNF vs Homebrew)
- Platform-specific helpers and dependencies

When mirroring, adapt the implementation for the target platform's package
manager and tools (DNF → `brew`, systemctl → `launchctl`, etc.), but keep the
same script name, metadata headers, and argument interface.

## Command Naming

All standalone scripts use the `rig-` prefix. Prefixes indicate purpose:

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

- `rig-cmd-missing` / `rig-cmd-present` - check for commands
- `rig-pkg-missing` / `rig-pkg-present` - check for packages
- `rig-pkg-add` - install packages (handles both Fedora and macOS)

## Code Style

See [AGENTS.md](./AGENTS.md) for full coding standards. Summary:

- **Indentation**: 2 spaces, no tabs
- **Shebangs**: `#!/bin/bash` (never `#!/usr/bin/env bash`)
- **Conditionals**: `[[ ]]` for strings/files, `(( ))` for numbers
- **Variables**: Don't quote in `[[ ]]`, do quote in commands
- **Commands**: Use `rig-cmd-*` helpers, not raw `command -v`

## Execution Model

```text
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
- **State tracking**: `~/.local/state/rig/migrations/`

```bash
# Create new migration (use --no-edit to skip editor)
rig-dev-add-migration --no-edit
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
   # rig:summary=Short description of the command
   # rig:usage=rig <cmd> [options] [args]

   set -euo pipefail
   # ... implementation
   ```

2. Make executable:

   ```bash
   chmod +x unix/fedora/bin/rig-<name>
   chmod +x unix/macos/bin/rig-<name>
   ```

3. Add to PATH in installer setup
4. If the command is not platform-specific, add it to both Fedora and macOS
   (follow the Cross-Platform Mirroring section)

### Adding Hardware Detection

1. Create script in `unix/{fedora,macos}/install/config/hardware/`
2. Check hardware in the script using `rig-hw-*` commands
3. Call from `hardware/all.sh` using `run_logged`

## Safe Patterns

### DO

- ✅ Use `run_logged` for work scripts
- ✅ Use `rig-cmd-*` helpers for command checks
- ✅ Keep platform-specific code in platform directories
- ✅ Share common code in `unix/common/`
- ✅ Test with `--only` flag for specific phases

### DON'T

- ❌ Never `source` work scripts (use `run_logged`)
- ❌ Never use `#!/usr/bin/env bash`
- ❌ Never use `local` outside functions
- ❌ Never hardcode paths (use `$RIG_*` variables)
- ❌ Never skip error handling in install scripts

## Troubleshooting

```bash
# Check syntax of a script
shellcheck -S error unix/fedora/bin/rig-*

# Run specific installer phase
./unix/fedora/fedora-setup --only packaging/all

# View installer logs
cat /var/log/rig-install.log

# Debug a command
bash -x unix/fedora/bin/rig-pkg-add test-pkg
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

- "Add support for Rust toolchain" → Update `packages/rust.packages`,
  add install script
- "Fix ASUS audio issues" → Edit `install/config/hardware/asus.sh`
- "Add PostgreSQL package" → Add to `packages/development.packages`
- "Create new migration for config change" → `rig-dev-add-migration`

## Out of Scope

This skill does not cover:

- User configuration editing (use rig-config skill)
- Non-installer shell scripting
- System administration after installation
