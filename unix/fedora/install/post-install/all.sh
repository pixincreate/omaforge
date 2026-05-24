#!/bin/bash
set -eEuo pipefail
# Post-installation tasks

log_section "Post-Installation"

run_logged "$RIG_INSTALL/post-install/finished.sh"
