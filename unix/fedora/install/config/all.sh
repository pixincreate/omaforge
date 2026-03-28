#!/bin/bash

set -eEuo pipefail

# Apply all system configurations

log_section "System Configuration"

run_logged "$OMAFORGE_INSTALL/config/system.sh"
run_logged "$OMAFORGE_INSTALL/config/appimage.sh"
run_logged "$OMAFORGE_INSTALL/config/firmware.sh"
run_logged "$OMAFORGE_INSTALL/config/git.sh"
run_logged "$OMAFORGE_INSTALL/config/ghostty.sh"
run_logged "$OMAFORGE_INSTALL/config/services.sh"
run_logged "$OMAFORGE_INSTALL/config/multimedia.sh"
run_logged "$OMAFORGE_INSTALL/config/performance.sh"
run_logged "$OMAFORGE_INSTALL/config/hardware/all.sh"
run_logged "$OMAFORGE_INSTALL/config/nextdns.sh"
run_logged "$OMAFORGE_INSTALL/config/secureboot.sh"
run_logged "$OMAFORGE_COMMON_INSTALL/config/skillset.sh"

log_success "All system configurations applied"
