#!/bin/bash
# Run all preflight checks

log_section "Preflight Checks"

source "$OMAFORGE_INSTALL/preflight/guard.sh"

log_success "All preflight checks passed"
