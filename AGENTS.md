# Style

- Two spaces for indentation, no tabs
- Use bash 5 conditionals: use `[[ ]]` for string/file tests and `(( ))` for numeric tests
- In `[[ ]]`, don't quote variables, but do quote string literals when comparing values (e.g., `[[ $branch == "main" ]]`)
- Prefer `(( ))` over numeric operators inside `[[ ]]` (e.g., `(( count < 50 ))`, not `[[ $count -lt 50 ]]`)
- For strings/paths with spaces, quote them instead of escaping spaces with `\ ` (e.g., `"$APP_DIR/Disk Usage.desktop"`, not `$APP_DIR/Disk\ Usage.desktop`)
- Shebangs must use `#!/bin/bash` consistently (never `#!/usr/bin/env bash`)

# Command Naming

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

# Helper Commands

Use these instead of raw shell commands:

- `omaforge-cmd-missing` / `omaforge-cmd-present` - check for commands
- `omaforge-pkg-missing` / `omaforge-pkg-present` - check for packages
- `omaforge-pkg-add` - install packages (handles both Fedora and macOS)

# Platform Support

Omaforge supports both Fedora and macOS:

- Fedora package manager: `dnf` (not pacman)
- AUR references: not applicable (Fedora uses COPR or manual builds)
- Platform detection: use `$OMAFORGE_PLATFORM` (set to `fedora` or `macos`)
- Platform-specific scripts: located in `unix/fedora/` and `unix/macos/`

# File Paths

Use these environment variables for consistency:

- `$OMAFORGE_PATH` - the omaforge repository root
- `$OMAFORGE_INSTALL` - install scripts directory
- Platform-specific directories: `unix/fedora/` and `unix/macos/`

# Logging

Use the logging helpers for consistent output:

- `log_info` - general information (cyan color)
- `log_success` - success messages (green color)
- `log_warning` - warnings (yellow color)
- `log_error` - errors (red color)
- `log_section` - section headers (bold/magenta)

All logging functions support colored output with ANSI codes for better readability.

# Execution Model

- Use `run_logged` for work scripts (executes in a subshell with logging)
- Use `source` only for helper libraries and sourcing functions
- Never `source` work scripts directly; always use `run_logged` to maintain proper scoping and logging

# Migrations

- No shebang line
- Start with an `echo` describing what the migration does
- Use `$OMAFORGE_PATH` to reference the omaforge directory

# Safe Patterns

**DO:**
- ✅ Use `run_logged` for work scripts
- ✅ Use `omaforge-cmd-*` helpers for command checks
- ✅ Keep platform-specific code in platform directories
- ✅ Share common code in `unix/common/`
- ✅ Test with `--only` flag for specific phases

**DON'T:**
- ❌ Never `source` work scripts (use `run_logged`)
- ❌ Never use `#!/usr/bin/env bash`
- ❌ Never use `local` outside functions
- ❌ Never hardcode paths (use `$OMAFORGE_*` variables)
- ❌ Never skip error handling in install scripts
