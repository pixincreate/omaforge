section "Fedora rig reset - no args shows help"
RESET_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig-reset" 2>&1 || true)
assert_output_contains "Shows usage" "Usage:" echo "$RESET_OUTPUT"
assert_output_contains "Shows subcommands" "Subcommands:" echo "$RESET_OUTPUT"
assert_output_contains "Shows zsh" "zsh" echo "$RESET_OUTPUT"
assert_output_contains "Shows stow" "stow" echo "$RESET_OUTPUT"
assert_output_contains "Shows fonts" "fonts" echo "$RESET_OUTPUT"
assert_output_contains "Shows hardware" "hardware" echo "$RESET_OUTPUT"
assert_output_contains "Shows webapps" "webapps" echo "$RESET_OUTPUT"
assert_output_contains "Shows rust" "rust" echo "$RESET_OUTPUT"

section "Fedora rig reset --help"
HELP_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig-reset" --help 2>&1)
assert_output_contains "--help shows usage" "Usage:" echo "$HELP_OUTPUT"

section "Fedora rig reset - unknown subcommand"
UNKNOWN_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig-reset" invalid_subcommand 2>&1 || true)
assert_output_contains "Shows error for unknown" "Unknown subcommand" echo "$UNKNOWN_OUTPUT"

section "Fedora rig reset has no interactive menu"
RESET_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig-reset" 2>&1 || true)
assert_output_not_contains "No numbered menu" "Choose option" echo "$RESET_OUTPUT"
assert_output_not_contains "No clear screen" "$(printf '\033c')" echo "$RESET_OUTPUT"
