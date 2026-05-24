#!/bin/bash
# Common logging functions for rig
# Shared between Fedora and macOS

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Log file for run_logged (can be overridden by platform scripts)
RIG_INSTALL_LOG_FILE="${RIG_INSTALL_LOG_FILE:-/var/log/rig-install.log}"

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

    local log_dir
    log_dir=$(dirname "$RIG_INSTALL_LOG_FILE")
    mkdir -p "$log_dir"

    # Truncate log on first run of the session
    if [[ -z "${RIG_LOG_INITIALIZED:-}" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Rig install started" >"$RIG_INSTALL_LOG_FILE"
        export RIG_LOG_INITIALIZED=1
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting: $script" >>"$RIG_INSTALL_LOG_FILE"

    # Run interactively: stdin passes through, output goes to both console and log
    bash -c "source '$RIG_INSTALL/helpers/all.sh'; source '$script'" 2>&1 | tee -a "$RIG_INSTALL_LOG_FILE"

    local exit_code=${PIPESTATUS[0]}

    if (( exit_code == 0 )); then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Completed: $script" >>"$RIG_INSTALL_LOG_FILE"
        unset CURRENT_SCRIPT
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $script (exit code: $exit_code)" >>"$RIG_INSTALL_LOG_FILE"
    fi

    return "$exit_code"
}

# Abort with error message
# Usage: abort "message"
abort() {
    log_error "$1"
    exit 1
}
