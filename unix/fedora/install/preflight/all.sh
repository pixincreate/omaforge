#!/bin/bash
set -eEuo pipefail
# Run all preflight checks

run_logged "$OMAFORGE_INSTALL/preflight/show-env.sh"
run_logged "$OMAFORGE_INSTALL/preflight/guard.sh"
