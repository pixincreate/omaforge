#!/bin/bash

log_section "Preflight Checks"

run_logged "$RIG_INSTALL/preflight/guard.sh"

log_success "All preflight checks passed"
