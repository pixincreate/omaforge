#!/bin/bash
section "macOS helpers load"
setup_rig_env "macos"
source "$RIG_REPO/unix/macos/install/helpers/all.sh"

assert_success "log_info is defined" type log_info
assert_success "log_success is defined" type log_success
assert_success "run_logged is defined" type run_logged
assert_success "confirm is defined" type confirm
assert_success "cmd_exists is defined" type cmd_exists
assert_success "get_config is defined" type get_config
assert_success "brew_installed is defined" type brew_installed

section "macOS dotfiles scripts syntax"
setup_rig_env "macos"
for f in "$RIG_INSTALL/dotfiles/"*.sh; do
    [[ -f "$f" ]] && assert_bash_syntax "$(basename "$f")" "$f"
done

section "macOS config scripts syntax"
setup_rig_env "macos"
for f in "$RIG_INSTALL/config/"*.sh; do
    [[ -f "$f" ]] && assert_bash_syntax "$(basename "$f")" "$f"
done

section "macOS packaging scripts syntax"
setup_rig_env "macos"
for f in "$RIG_INSTALL/packaging/"*.sh; do
    [[ -f "$f" ]] && assert_bash_syntax "$(basename "$f")" "$f"
done
