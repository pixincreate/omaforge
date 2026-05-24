#!/bin/bash
set -eEuo pipefail

log_section "External Repositories"

run_logged "$RIG_COMMON_INSTALL/external/skillset.sh"

log_success "External repositories configured"
