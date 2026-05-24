#!/bin/bash
set -eEuo pipefail
# Fedora-specific logging configuration

RIG_INSTALL_LOG_FILE="$HOME/.local/state/rig/install.log"
export RIG_INSTALL_LOG_FILE
