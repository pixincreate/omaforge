#!/bin/bash
section "Common libexec scripts metadata"
assert_success "rig-reset has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/common/libexec/rig-reset"
assert_success "rig-reset has usage" grep -q 'rig:usage=' "$RIG_REPO/unix/common/libexec/rig-reset"
assert_success "rig-pkg-add has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/common/libexec/rig-pkg-add"
assert_success "rig-pkg-remove has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/common/libexec/rig-pkg-remove"
assert_success "rig-pkg-search has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/common/libexec/rig-pkg-search"
assert_success "rig-pkg-list has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/common/libexec/rig-pkg-list"
assert_success "rig-drift has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/common/libexec/rig-drift"
assert_success "rig add aliases pkg-add" grep -q 'add) set -- pkg-add' "$RIG_REPO/unix/fedora/bin/rig"
assert_success "rig-migrate has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/fedora/libexec/rig-migrate"
assert_success "rig-launch-webapp has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/fedora/libexec/rig-launch-webapp"
assert_success "rig-webapp-install has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/fedora/libexec/rig-webapp-install"
assert_success "rig-webapp-remove has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/fedora/libexec/rig-webapp-remove"

section "Fedora bin scripts syntax"
for f in "$RIG_REPO/unix/fedora/bin/"*; do
    [[ -f "$f" ]] && assert_bash_syntax "$(basename "$f")" "$f"
done

section "Fedora bin scripts shellcheck"
if command -v shellcheck &>/dev/null; then
    for f in "$RIG_REPO/unix/fedora/bin/"*; do
        [[ -f "$f" ]] && assert_shellcheck "$(basename "$f")" "$f"
    done
fi

section "Fedora rig pkg-add no args"
PKG_ADD_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig" pkg-add 2>&1 || true)
assert_output_contains "Shows usage" "Usage:" echo "$PKG_ADD_OUTPUT"

section "Fedora rig pkg-remove no args"
PKG_REMOVE_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig" pkg-remove 2>&1 || true)
assert_output_contains "Shows usage" "Usage:" echo "$PKG_REMOVE_OUTPUT"
assert_output_not_contains "No fzf" "fzf" echo "$PKG_REMOVE_OUTPUT"

section "Fedora rig pkg-search no args"
PKG_SEARCH_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig" pkg-search 2>&1 || true)
assert_output_contains "Shows usage" "Usage:" echo "$PKG_SEARCH_OUTPUT"

section "Fedora rig pkg-list overview"
PKG_LIST_OUTPUT=$(bash "$RIG_REPO/unix/fedora/bin/rig" pkg-list 2>&1 || true)
assert_output_contains "Shows overview" "Package lists (fedora)" echo "$PKG_LIST_OUTPUT"

section "Fedora rig drift dry run"
DRIFT_OUTPUT=$(NON_INTERACTIVE=true bash "$RIG_REPO/unix/fedora/bin/rig" drift 2>&1 || true)
assert_output_contains "Runs dry-run report" "Drift report (fedora)" echo "$DRIFT_OUTPUT"
assert_output_not_contains "Applies without flag" "Converging" echo "$DRIFT_OUTPUT"

section "Fedora package lists content"
for f in "$RIG_REPO/unix/fedora/packages/"*.packages; do
    [[ -f "$f" ]] && assert_success "$(basename "$f") is non-empty" test -s "$f"
done

section "Fedora config validation"
assert_success "config.json is valid JSON" jq empty "$RIG_REPO/unix/fedora/config.json"
