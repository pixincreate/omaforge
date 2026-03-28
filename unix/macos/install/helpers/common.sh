#!/bin/bash
# macOS-specific helper functions

brew_installed() {
    brew list "$1" &>/dev/null 2>&1
}
