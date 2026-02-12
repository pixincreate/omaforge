#!/bin/bash
# GNU Stow dotfiles deployment for macOS

echo "Deploying dotfiles with GNU Stow"

# Get stow configuration
stow_dir=$(expand_path "$(get_config '.dotfiles.stow_source')")
target_dir="$HOME"

# Read packages into array (compatible with bash 3.2)
packages=()
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    packages+=("$line")
done < <(get_config_array '.dotfiles.stow_packages')

# Source common stow script
COMMON_SCRIPT="$OMAFORGE_PATH/../common/dotfiles/stow.sh"

if [[ ! -f "$COMMON_SCRIPT" ]]; then
    log_error "Common stow script not found: $COMMON_SCRIPT"
    return 1
fi

source "$COMMON_SCRIPT"

# Run stow with macOS config values
stow_dotfiles "$stow_dir" "$target_dir" "${packages[@]}"
