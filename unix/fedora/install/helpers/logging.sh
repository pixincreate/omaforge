#!/bin/bash
set -eEuo pipefail
# Fedora-specific logging configuration

OMAFORGE_INSTALL_LOG_FILE="$HOME/.local/state/omaforge/install.log"
export OMAFORGE_INSTALL_LOG_FILE
