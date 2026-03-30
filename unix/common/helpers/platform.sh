#!/bin/bash
set -eEuo pipefail

# Platform detection helper
# Returns: macos, fedora, debian, android, or unknown

detect_platform() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ -f /etc/fedora-release ]]; then
    echo "fedora"
  elif [[ -f /etc/debian_version ]]; then
    echo "debian"
  elif [[ -n "${TERMUX_VERSION:-}" ]] || [[ -d /data/data/com.termux ]]; then
    echo "android"
  else
    echo "unknown"
  fi
}
