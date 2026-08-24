#!/bin/bash
section "Fedora dispatcher help output"
DISPLAY_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig" 2>&1)

assert_output_contains "Shows usage header" "Usage: rig <command>" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows add command" "add" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows reset command" "reset" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows stow command" "stow" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows pkg-add command" "pkg-add" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows pkg-remove command" "pkg-remove" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows pkg-search command" "pkg-search" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows pkg-list command" "pkg-list" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows migrate command" "migrate" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows launch-webapp command" "launch-webapp" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows webapp-install command" "webapp-install" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows webapp-remove command" "webapp-remove" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows install-skillset command" "install-skillset" echo "$DISPLAY_OUTPUT"

section "Fedora dispatcher --help"
HELP_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig" --help 2>&1)
assert_output_contains "--help shows commands" "Usage: rig <command>" echo "$HELP_OUTPUT"

section "Fedora dispatcher error on unknown"
UNKNOWN_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig" nonexistent 2>&1 || true)
assert_output_contains "Shows error for unknown" "unknown command" echo "$UNKNOWN_OUTPUT"

section "Fedora dispatcher multi-word routing"
# rig reset should route to rig-reset
RESET_HELP=$(bash "$RIG_REPO/unix/fedora/bin/rig" reset --help 2>&1)
assert_output_contains "rig reset shows subcommands" "Subcommands (fedora):" echo "$RESET_HELP"
assert_output_contains "rig reset shows fonts" "fonts" echo "$RESET_HELP"
assert_output_contains "rig reset shows zsh" "zsh" echo "$RESET_HELP"
assert_output_contains "rig reset shows stow" "stow" echo "$RESET_HELP"
assert_output_contains "rig reset shows git" "git" echo "$RESET_HELP"
assert_output_contains "rig reset shows rust" "rust" echo "$RESET_HELP"

# --help flag on subcommand
PKG_HELP=$(bash "$RIG_REPO/unix/fedora/bin/rig" pkg-list --help 2>&1)
assert_output_contains "rig pkg-list --help shows usage" "Usage:" echo "$PKG_HELP"
