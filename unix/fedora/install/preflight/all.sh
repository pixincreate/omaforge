#!/bin/bash
set -eEuo pipefail
# Run all preflight checks

run_logged "$RIG_INSTALL/preflight/show-env.sh"
run_logged "$RIG_INSTALL/preflight/guard.sh"
