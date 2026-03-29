#!/bin/bash
# Hardware detection and configuration

source "$OMAFORGE_INSTALL/helpers/all.sh"

log_info "Detecting and configuring hardware"

run_logged "$OMAFORGE_INSTALL/config/hardware/asus.sh" || exit 1
run_logged "$OMAFORGE_INSTALL/config/hardware/nvidia.sh" || exit 1

log_success "Hardware configuration completed"
