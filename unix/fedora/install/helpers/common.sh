#!/bin/bash
set -eEuo pipefail
# Fedora-specific helper functions

pkg_installed() {
    rpm -q "$1" &>/dev/null 2>&1
}
