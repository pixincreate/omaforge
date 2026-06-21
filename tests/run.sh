#!/bin/bash
# Rig test runner
# Usage: tests/run.sh [--fedora|--macos|--all] [test_name...]

set -euo pipefail

RIG_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export RIG_REPO

source "$RIG_REPO/tests/test_helper.sh"

TESTS_DIR="$RIG_REPO/tests"
RUN_FEDORA=false
RUN_MACOS=false
RUN_COMMON=false
declare -a FILTERS=()

parse_args() {
    if [[ $# -eq 0 ]]; then
        RUN_FEDORA=true
        RUN_MACOS=true
        RUN_COMMON=true
        return
    fi

    for arg in "$@"; do
        case "$arg" in
            --fedora) RUN_FEDORA=true ;;
            --macos) RUN_MACOS=true ;;
            --common) RUN_COMMON=true ;;
            --all)
                RUN_FEDORA=true
                RUN_MACOS=true
                RUN_COMMON=true
                ;;
            -h|--help)
                echo "Usage: $0 [--fedora|--macos|--common|--all] [test_name...]"
                echo ""
                echo "Examples:"
                echo "  $0 --all                  # Run all tests"
                echo "  $0 --fedora               # Run only Fedora tests"
                echo "  $0 --fedora syntax        # Run Fedora syntax tests only"
                echo "  $0 --macos dispatcher     # Run macOS dispatcher tests only"
                exit 0
                ;;
            *)
                FILTERS+=("$arg")
                ;;
        esac
    done

    if ! $RUN_FEDORA && ! $RUN_MACOS && ! $RUN_COMMON; then
        RUN_FEDORA=true
        RUN_MACOS=true
        RUN_COMMON=true
    fi
}

run_test_suite() {
    local platform="$1"   # "fedora", "macos", or "common"
    local dir="$TESTS_DIR/$platform"
    local filters=("${@:2}")

    if [[ ! -d "$dir" ]]; then
        return
    fi

    # Find test files
    local test_files=()
    if [[ ${#filters[@]} -gt 0 ]]; then
        for filter in "${filters[@]}"; do
            local file="$dir/$filter.test.sh"
            if [[ -f "$file" ]]; then
                test_files+=("$file")
            fi
        done
    else
        for file in "$dir"/*.test.sh; do
            [[ -f "$file" ]] && test_files+=("$file")
        done
    fi

    if [[ ${#test_files[@]} -eq 0 ]]; then
        echo -e "${TC_YELLOW}No test files found for $platform${TC_RESET}"
        return
    fi

    for test_file in "${test_files[@]}"; do
        init_tests
        local test_name
        test_name=$(basename "$test_file" .test.sh)
        echo ""
        echo -e "${TC_YELLOW}══════════════════════════════════════════════${TC_RESET}"
        echo -e "${TC_YELLOW}  Platform: $platform  |  Suite: $test_name${TC_RESET}"
        echo -e "${TC_YELLOW}══════════════════════════════════════════════${TC_RESET}"
        # shellcheck source=/dev/null
        source "$test_file"
        finish_tests || return 1
    done
}

main() {
    parse_args "$@"
    local exit_code=0

    echo -e "${TC_BLUE}══════════════════════════════════════════════${TC_RESET}"
    echo -e "${TC_BLUE}  Rig Test Runner${TC_RESET}"
    echo -e "${TC_BLUE}  Repo: $RIG_REPO${TC_RESET}"
    echo -e "${TC_BLUE}══════════════════════════════════════════════${TC_RESET}"

    if $RUN_COMMON; then
        run_test_suite "common" "${FILTERS[@]}" || exit_code=1
    fi

    if $RUN_FEDORA; then
        run_test_suite "fedora" "${FILTERS[@]}" || exit_code=1
    fi

    if $RUN_MACOS; then
        run_test_suite "macos" "${FILTERS[@]}" || exit_code=1
    fi

    if [[ $exit_code -eq 0 ]]; then
        echo -e "${TC_GREEN}All test suites passed!${TC_RESET}"
    else
        echo -e "${TC_RED}Some test suites failed!${TC_RESET}"
    fi

    exit "$exit_code"
}

main "$@"
