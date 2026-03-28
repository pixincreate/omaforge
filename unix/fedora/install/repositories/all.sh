#!/bin/bash
set -eEuo pipefail
# Setup all repositories

log_section "Repository Setup"

run_logged "$OMAFORGE_INSTALL/repositories/rpmfusion.sh"
run_logged "$OMAFORGE_INSTALL/repositories/copr.sh"
run_logged "$OMAFORGE_INSTALL/repositories/terra.sh"
run_logged "$OMAFORGE_INSTALL/repositories/external.sh"

# Refresh repository metadata
log_info "Refreshing repository metadata"
sudo dnf check-update -y || true

log_success "All repositories configured"
