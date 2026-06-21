#!/bin/bash
# Test helper: shared utilities for rig tests

# Colors
TC_RED='\033[0;31m'
TC_GREEN='\033[0;32m'
TC_YELLOW='\033[1;33m'
TC_BLUE='\033[0;34m'
TC_RESET='\033[0m'

PASS=0
FAIL=0
TOTAL=0

# Initialize test run
init_tests() {
    PASS=0
    FAIL=0
    TOTAL=0
}

# Print a test section header
section() {
    echo ""
    echo -e "${TC_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${TC_RESET}"
    echo -e "${TC_BLUE}  $*${TC_RESET}"
    echo -e "${TC_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${TC_RESET}"
    echo ""
}

# Assert that a command succeeds
assert_success() {
    local desc="$1"
    shift
    TOTAL=$((TOTAL + 1))
    if "$@" &>/dev/null; then
        echo -e "  ${TC_GREEN}✓${TC_RESET} $desc"
        PASS=$((PASS + 1))
    else
        echo -e "  ${TC_RED}✗${TC_RESET} $desc"
        echo -e "    ${TC_YELLOW}Command: $*${TC_RESET}"
        FAIL=$((FAIL + 1))
    fi
}

# Assert that a command fails
assert_failure() {
    local desc="$1"
    shift
    TOTAL=$((TOTAL + 1))
    if ! "$@" &>/dev/null; then
        echo -e "  ${TC_GREEN}✓${TC_RESET} $desc"
        PASS=$((PASS + 1))
    else
        echo -e "  ${TC_RED}✗${TC_RESET} $desc"
        echo -e "    ${TC_YELLOW}Expected failure but succeeded: $*${TC_RESET}"
        FAIL=$((FAIL + 1))
    fi
}

# Assert that output contains a string
assert_output_contains() {
    local desc="$1"
    local expected="$2"
    shift 2
    TOTAL=$((TOTAL + 1))
    local output
    output=$("$@" 2>&1)
    if echo "$output" | grep -qF "$expected"; then
        echo -e "  ${TC_GREEN}✓${TC_RESET} $desc"
        PASS=$((PASS + 1))
    else
        echo -e "  ${TC_RED}✗${TC_RESET} $desc"
        echo -e "    ${TC_YELLOW}Expected output to contain: $expected${TC_RESET}"
        echo -e "    ${TC_YELLOW}Got:${TC_RESET}"
        echo "$output" | head -5 | sed 's/^/    /'
        FAIL=$((FAIL + 1))
    fi
}

# Assert that output does NOT contain a string
assert_output_not_contains() {
    local desc="$1"
    local unexpected="$2"
    shift 2
    TOTAL=$((TOTAL + 1))
    local output
    output=$("$@" 2>&1)
    if ! echo "$output" | grep -qF "$unexpected"; then
        echo -e "  ${TC_GREEN}✓${TC_RESET} $desc"
        PASS=$((PASS + 1))
    else
        echo -e "  ${TC_RED}✗${TC_RESET} $desc"
        echo -e "    ${TC_YELLOW}Output unexpectedly contains: $unexpected${TC_RESET}"
        FAIL=$((FAIL + 1))
    fi
}

# Assert that a file has valid bash syntax
assert_bash_syntax() {
    local desc="$1"
    local file="$2"
    TOTAL=$((TOTAL + 1))
    if bash -n "$file" 2>/dev/null; then
        echo -e "  ${TC_GREEN}✓${TC_RESET} $desc"
        PASS=$((PASS + 1))
    else
        echo -e "  ${TC_RED}✗${TC_RESET} $desc"
        echo -e "    ${TC_YELLOW}Syntax error in: $file${TC_RESET}"
        bash -n "$file" 2>&1 | sed 's/^/    /'
        FAIL=$((FAIL + 1))
    fi
}

# Assert shellcheck passes (skip if shellcheck not available)
assert_shellcheck() {
    local desc="$1"
    local file="$2"
    TOTAL=$((TOTAL + 1))
    if ! command -v shellcheck &>/dev/null; then
        echo -e "  ${TC_YELLOW}⚠${TC_RESET} $desc (shellcheck not available, SKIPPED)"
        PASS=$((PASS + 1))
        return
    fi
    if shellcheck -e SC1091 "$file" 2>/dev/null; then
        echo -e "  ${TC_GREEN}✓${TC_RESET} $desc"
        PASS=$((PASS + 1))
    else
        echo -e "  ${TC_RED}✗${TC_RESET} $desc"
        shellcheck -e SC1091 "$file" 2>&1 | sed 's/^/    /'
        FAIL=$((FAIL + 1))
    fi
}

# Assert that a command's output matches exactly
assert_output_eq() {
    local desc="$1"
    local expected="$2"
    local actual
    shift 2
    actual=$("$@" 2>&1)
    TOTAL=$((TOTAL + 1))
    if [[ "$actual" == "$expected" ]]; then
        echo -e "  ${TC_GREEN}✓${TC_RESET} $desc"
        PASS=$((PASS + 1))
    else
        echo -e "  ${TC_RED}✗${TC_RESET} $desc"
        echo -e "    ${TC_YELLOW}Expected: $expected${TC_RESET}"
        echo -e "    ${TC_YELLOW}Actual:   $actual${TC_RESET}"
        FAIL=$((FAIL + 1))
    fi
}

# Print test results and return exit code
finish_tests() {
    echo ""
    echo -e "${TC_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${TC_RESET}"
    echo -e "  Results: ${TC_GREEN}$PASS passed${TC_RESET}, ${TC_RED}$FAIL failed${TC_RESET}, $TOTAL total"
    echo -e "${TC_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${TC_RESET}"
    echo ""
    return "$FAIL"
}

# Set up RIG environment vars for testing
setup_rig_env() {
    local platform="$1"  # "fedora" or "macos"
    export RIG_PATH="$RIG_REPO/unix/$platform"
    export RIG_INSTALL="$RIG_PATH/install"
    export RIG_CONFIG="$RIG_PATH/config.json"
    export RIG_BIN="$RIG_PATH/bin"
    export NON_INTERACTIVE=true
    export RIG_INSTALL_LOG_FILE="/tmp/rig-test-$$.log"
    mkdir -p "$(dirname "$RIG_INSTALL_LOG_FILE")"
}

# Source helpers for a platform
source_helpers() {
    local platform="$1"
    setup_rig_env "$platform"
    if [[ -f "$RIG_INSTALL/helpers/all.sh" ]]; then
        source "$RIG_INSTALL/helpers/all.sh"
    fi
}
