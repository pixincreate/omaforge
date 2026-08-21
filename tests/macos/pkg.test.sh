#!/bin/bash
section "macOS bin scripts metadata"
assert_success "rig-reset has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/macos/libexec/rig-reset"
assert_success "rig-reset has usage" grep -q 'rig:usage=' "$RIG_REPO/unix/macos/libexec/rig-reset"
assert_success "rig-pkg-add has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/macos/libexec/rig-pkg-add"
assert_success "rig-pkg-remove has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/macos/libexec/rig-pkg-remove"
assert_success "rig-pkg-search has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/macos/libexec/rig-pkg-search"
assert_success "rig-pkg-list has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/macos/libexec/rig-pkg-list"
assert_success "rig-stow has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/macos/libexec/rig-stow"
assert_success "rig-add has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/macos/libexec/rig-add"

section "macOS bin scripts syntax"
for f in "$RIG_REPO/unix/macos/bin/"*; do
    [[ -f "$f" ]] && assert_bash_syntax "$(basename "$f")" "$f"
done

section "macOS bin scripts shellcheck"
if command -v shellcheck &>/dev/null; then
    for f in "$RIG_REPO/unix/macos/bin/"*; do
        [[ -f "$f" ]] && assert_shellcheck "$(basename "$f")" "$f"
    done
fi

section "macOS rig pkg-add no args"
PKG_ADD_OUTPUT=$(bash "$RIG_REPO/unix/macos/libexec/rig-pkg-add" 2>&1 || true)
assert_output_contains "Shows usage" "Usage:" echo "$PKG_ADD_OUTPUT"
assert_output_contains "Shows types" "brew" echo "$PKG_ADD_OUTPUT"
assert_output_contains "Shows cask" "cask" echo "$PKG_ADD_OUTPUT"

section "macOS rig pkg-remove no args"
PKG_REMOVE_OUTPUT=$(bash "$RIG_REPO/unix/macos/libexec/rig-pkg-remove" 2>&1 || true)
assert_output_contains "Shows usage" "Usage:" echo "$PKG_REMOVE_OUTPUT"

section "macOS rig pkg-search no args"
PKG_SEARCH_OUTPUT=$(bash "$RIG_REPO/unix/macos/libexec/rig-pkg-search" 2>&1 || true)
assert_output_contains "Shows usage" "Usage:" echo "$PKG_SEARCH_OUTPUT"

section "macOS rig pkg-list no args"
PKG_LIST_OUTPUT=$(bash "$RIG_REPO/unix/macos/libexec/rig-pkg-list" 2>&1 || true)
assert_output_contains "Shows usage" "Usage:" echo "$PKG_LIST_OUTPUT"

section "macOS package lists content"
for f in "$RIG_REPO/unix/macos/packages/"*.packages; do
    [[ -f "$f" ]] && assert_success "$(basename "$f") is non-empty" test -s "$f"
done

section "macOS config validation"
assert_success "config.json is valid JSON" jq empty "$RIG_REPO/unix/macos/config.json"
