# Style

- Two spaces for indentation, no tabs
- Use bash 5 conditionals: use `[[ ]]` for string/file tests
  and `(( ))` for numeric tests
- In `[[ ]]`, don't quote variables, but do quote string literals
  when comparing values (e.g., `[[ $branch == "main" ]]`)
- Prefer `(( ))` over numeric operators inside `[[ ]]`
  (e.g., `(( count < 50 ))`, not `[[ $count -lt 50 ]]`)
- For strings/paths with spaces, quote them instead of escaping
  spaces with a backslash (e.g., `"$APP_DIR/Disk Usage.desktop"`)
- Shebangs must use `#!/bin/bash` consistently (never `#!/usr/bin/env bash`)

## Unified CLI Dispatcher

Run `rig` with no arguments to list all available commands with their
descriptions:

```bash
rig                         # List all commands
rig stow --all              # Same as rig stow --all
rig add base neovim         # Same as rig add base neovim
rig install skillset        # Multi-word prefix routing
```

Each platform has its own dispatcher (`unix/fedora/bin/rig` and
`unix/macos/bin/rig`) with the same interface. The dispatcher also checks
`unix/common/libexec/` for commands shared across both platforms.

**Multi-word prefix routing**: the dispatcher tries each prefix from
all-words-down-to-1 to find a matching `rig-<words>` binary. For example,
`rig install skillset` → `rig-install-skillset`.

The dispatcher reads `# rig:summary=` and `# rig:usage=`
metadata from each script. The metadata format is:

```bash
# rig:summary=Short description of the command
# rig:usage=rig <cmd> [options] [args]
```

Always add these annotations to new scripts so they appear in the help output.

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

## Platform Support

Rig supports both Fedora and macOS:

- Fedora package manager: `dnf` (not pacman)
- AUR references: not applicable (Fedora uses COPR or manual builds)
- Platform detection: use `$RIG_PLATFORM` (set to `fedora` or `macos`)
- Platform-specific scripts: located in `unix/fedora/` and `unix/macos/`

## File Paths

Use these environment variables for consistency:

- `$RIG_PATH` - the rig repository root
- `$RIG_INSTALL` - install scripts directory
- Platform-specific directories: `unix/fedora/` and `unix/macos/`

## Logging

Use the logging helpers for consistent output:

- `log_info` - general information (cyan color)
- `log_success` - success messages (green color)
- `log_warning` - warnings (yellow color)
- `log_error` - errors (red color)
- `log_section` - section headers (bold/magenta)

All logging functions support colored output with ANSI codes for better
readability.

## Execution Model

- Use `run_logged` for work scripts (executes in a subshell with logging)
- Use `source` only for helper libraries and sourcing functions
- Never `source` work scripts directly; always use `run_logged`
  to maintain proper scoping and logging

## Cross-Platform Consistency

Rig supports Fedora _and_ macOS with mirrored directory structures under
`unix/fedora/` and `unix/macos/`. **When you make changes that are not
platform-specific, you must apply the equivalent change to both platforms.**

**Requires mirroring:**

- New or modified `libexec/` scripts (add/update in both
  `unix/fedora/libexec/` and `unix/macos/libexec/`)
- Changes to package lists for shared tools (add to Fedora's
  `packages/` _and_ macOS's `packages/`)
- New install modules that aren't hardware-specific
- Changes to `unix/common/` helpers (already shared by default)
- Updates to documentation (README.md on both platforms)

**Platform-specific (no mirroring needed):**

- Fedora-only hardware support (ASUS, NVIDIA audio, etc.)
- macOS-only system configuration
- Package managers (DNF vs Homebrew — different tool, same intent)
- KDE-specific or macOS-specific config

When mirroring, adapt for the target platform's tooling but keep script names,
metadata headers, and argument interfaces consistent.

## Migrations

- No shebang line
- Start with an `echo` describing what the migration does
- Use `$RIG_PATH` to reference the rig directory

## Safe Patterns

**DO:**

- ✅ Use `run_logged` for work scripts
- ✅ Use `rig-cmd-*` helpers for command checks
- ✅ Keep platform-specific code in platform directories
- ✅ Share common code in `unix/common/`
- ✅ Test with `--only` flag for specific phases

**DON'T:**

- ❌ Never `source` work scripts (use `run_logged`)
- ❌ Never use `#!/usr/bin/env bash`
- ❌ Never use `local` outside functions
- ❌ Never hardcode paths (use `$RIG_*` variables)
- ❌ Never skip error handling in install scripts
