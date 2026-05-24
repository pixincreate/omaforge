#!/bin/bash
set -eEuo pipefail
# Manage all dotfiles

log_section "Dotfiles Management"

run_logged "$RIG_INSTALL/dotfiles/directories.sh"
run_logged "$RIG_INSTALL/dotfiles/zsh.sh"
run_logged "$RIG_INSTALL/dotfiles/stow.sh"
run_logged "$RIG_INSTALL/dotfiles/fonts.sh"

log_success "Dotfiles management completed"
