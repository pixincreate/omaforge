#!/bin/bash

log_section "System Configuration"

run_logged "$OMAFORGE_INSTALL/config/system.sh"
run_logged "$OMAFORGE_INSTALL/config/git.sh"
run_logged "$OMAFORGE_INSTALL/config/nextdns.sh"
run_logged "$OMAFORGE_COMMON_INSTALL/config/skillset.sh"

log_success "All system configurations applied"
