#!/bin/bash
set -eEuo pipefail
# Install all packages

log_section "Package Installation"

run_logged "$OMAFORGE_INSTALL/packaging/base.sh"
run_logged "$OMAFORGE_INSTALL/packaging/bloatware.sh"
run_logged "$OMAFORGE_INSTALL/packaging/flatpak.sh"
run_logged "$OMAFORGE_INSTALL/packaging/npm.sh"
run_logged "$OMAFORGE_INSTALL/packaging/rust.sh"
run_logged "$OMAFORGE_INSTALL/packaging/webapps.sh"

log_success "All packages installed"
