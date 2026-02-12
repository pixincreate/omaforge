#!/bin/bash
# Install all packages

log_section "Package Installation"

source "$OMAFORGE_INSTALL/packaging/homebrew.sh"
source "$OMAFORGE_INSTALL/packaging/brew.sh"
source "$OMAFORGE_INSTALL/packaging/cask.sh"
source "$OMAFORGE_INSTALL/packaging/rust.sh"

log_success "All packages installed"
