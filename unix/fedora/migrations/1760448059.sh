#!/bin/bash
set -eEuo pipefail

# Migration: Install Topgrade

echo "Running migration: Install Topgrade"

# Route through the platform dispatcher (pkg workers live in unix/common/libexec now).
RIG_DISPATCHER="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/rig"

# Check if already installed (idempotency)
if rpm -q topgrade &>/dev/null; then
    echo "[INFO] Topgrade already installed, skipping"
    exit 0
fi

# Use the package manager command
if ! "$RIG_DISPATCHER" pkg-add base topgrade; then
    echo "[ERROR] Failed to install Topgrade"
    exit 1
fi

echo "[SUCCESS] Migration completed: Topgrade has been installed"
