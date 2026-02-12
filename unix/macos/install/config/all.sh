#!/bin/bash
# Apply all system configurations

log_section "System Configuration"

source "$OMAFORGE_INSTALL/config/system.sh"
source "$OMAFORGE_INSTALL/config/git.sh"
source "$OMAFORGE_INSTALL/config/nextdns.sh"

log_success "All system configurations applied"
