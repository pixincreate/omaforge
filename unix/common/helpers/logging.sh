#!/bin/bash
# Common logging functions for omaforge
# Shared between Fedora and macOS

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Log file for run_logged (can be overridden by platform scripts)
OMAFORGE_INSTALL_LOG_FILE="${OMAFORGE_INSTALL_LOG_FILE:-/var/log/omaforge-install.log}"

# Check if output is a TTY for color support
__use_color() {
    [[ -t 1 ]]
}

log_info() {
    if __use_color; then
        echo -e "${BLUE}[INFO]${RESET} $*"
    else
        echo "[INFO] $*"
    fi
}

log_success() {
    if __use_color; then
        echo -e "${GREEN}[SUCCESS]${RESET} $*"
    else
        echo "[SUCCESS] $*"
    fi
}

log_warning() {
    if __use_color; then
        echo -e "${YELLOW}[WARNING]${RESET} $*" >&2
    else
        echo "[WARNING] $*" >&2
    fi
}

log_error() {
    if __use_color; then
        echo -e "${RED}[ERROR]${RESET} $*" >&2
    else
        echo "[ERROR] $*" >&2
    fi
}

log_section() {
    echo ""
    echo -e "${MAGENTA}=== $* ===${RESET}"
    echo ""
}

log_header() {
    echo ""
    echo "================================================================================"
    echo "$*"
    echo "================================================================================"
    echo ""
}

# Run a script in a subshell with logging
# Usage: run_logged /path/to/script.sh
run_logged() {
    local script="$1"
    export CURRENT_SCRIPT="$script"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $script" >>"$OMAFORGE_INSTALL_LOG_FILE"

    bash -c "source '$script'" </dev/null >>"$OMAFORGE_INSTALL_LOG_FILE" 2>&1

    local exit_code=$?

    if (( exit_code == 0 )); then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Completed: $script" >>"$OMAFORGE_INSTALL_LOG_FILE"
        unset CURRENT_SCRIPT
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $script (exit code: $exit_code)" >>"$OMAFORGE_INSTALL_LOG_FILE"
    fi

    return $exit_code
}

# Abort with error message
# Usage: abort "message"
abort() {
    log_error "$1"
    exit 1
}
