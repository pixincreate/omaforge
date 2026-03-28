#!/bin/bash

log_section "Package Installation"

run_logged "$OMAFORGE_INSTALL/packaging/homebrew.sh"
run_logged "$OMAFORGE_INSTALL/packaging/brew.sh"
run_logged "$OMAFORGE_INSTALL/packaging/cask.sh"
run_logged "$OMAFORGE_INSTALL/packaging/rust.sh"

log_success "All packages installed"
