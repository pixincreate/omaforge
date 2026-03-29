#!/bin/bash

set -e

stow_dotfiles() {
    local stow_dir="${1:-$HOME/.dotfiles/home}"
    local target_dir="${2:-$HOME}"
    shift 2
    local packages=("$@")

    echo "Managing dotfiles with Stow"

    if ! command -v stow &>/dev/null; then
        echo "[ERROR] GNU Stow is not installed"
        echo "[INFO] Install stow:"
        echo "  - macOS: brew install stow"
        echo "  - Fedora: sudo dnf install stow"
        return 1
    fi

    if [[ ! -d "$stow_dir" ]]; then
        echo "[ERROR] Stow directory not found: $stow_dir"
        return 1
    fi

    local failed=0
    for pkg in "${packages[@]}"; do
        pkg_dir="$stow_dir/$pkg"

        if [[ ! -d "$pkg_dir" ]]; then
            echo "[WARNING] Package directory not found: $pkg_dir"
            continue
        fi

        echo "[INFO] Stowing package: $pkg"

        if stow --no-folding --restow --dir="$stow_dir" --target="$target_dir" "$pkg"; then
            echo "[SUCCESS] Successfully stowed: $pkg"
        else
            echo "[WARNING] Stow conflict detected for: $pkg"

            if confirm "Adopt existing files for $pkg? (takes ownership of existing files)" "N"; then
                echo "[INFO] Adopting existing files for: $pkg"
                if stow --no-folding --restow --adopt --dir="$stow_dir" --target="$target_dir" "$pkg"; then
                    echo "[SUCCESS] Successfully stowed with adopt: $pkg"
                else
                    echo "[ERROR] Failed to stow $pkg even with --adopt"
                    failed=$((failed + 1))
                fi
            else
                echo "[INFO] Skipped stowing: $pkg"
                failed=$((failed + 1))
            fi
        fi
    done

    if (( failed > 0 )); then
        echo "[WARNING] $failed package(s) had conflicts. See log above for resolution commands."
        return 1
    fi

    echo "[SUCCESS] Dotfiles stowing completed"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    stow_dotfiles "$@"
fi
