section "macOS dispatcher help output"
DISPLAY_OUTPUT=$(bash "$RIG_REPO/unix/macos/bin/rig" 2>&1)

assert_output_contains "Shows usage header" "Usage: rig <command>" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows add command" "add" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows reset command" "reset" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows stow command" "stow" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows pkg-add command" "pkg-add" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows pkg-remove command" "pkg-remove" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows pkg-search command" "pkg-search" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows pkg-list command" "pkg-list" echo "$DISPLAY_OUTPUT"
assert_output_contains "Shows install-skillset command" "install-skillset" echo "$DISPLAY_OUTPUT"

# Should NOT show fedora-specific commands
assert_output_not_contains "Does not show migrate command" "migrate" echo "$DISPLAY_OUTPUT"
assert_output_not_contains "Does not show launch-webapp" "launch-webapp" echo "$DISPLAY_OUTPUT"

section "macOS dispatcher multi-word routing"
RESET_HELP=$(bash "$RIG_REPO/unix/macos/bin/rig" reset --help 2>&1)
assert_output_contains "rig reset shows subcommands" "Subcommands:" echo "$RESET_HELP"
assert_output_contains "rig reset shows fonts" "fonts" echo "$RESET_HELP"
assert_output_contains "rig reset shows rust" "rust" echo "$RESET_HELP"
