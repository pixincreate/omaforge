#!/bin/bash
# Hardware detection and configuration

echo "Detecting and configuring hardware"

run_logged "$OMAFORGE_INSTALL/config/hardware/asus.sh"
run_logged "$OMAFORGE_INSTALL/config/hardware/nvidia.sh"

log_success "Hardware configuration completed"
