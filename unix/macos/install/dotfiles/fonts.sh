#!/bin/bash
# Font installation for macOS - Downloads and installs fonts from GitHub releases

# Source common fonts script
COMMON_SCRIPT="$OMAFORGE_PATH/../common/dotfiles/fonts.sh"

if [[ ! -f "$COMMON_SCRIPT" ]]; then
    log_error "Common fonts script not found: $COMMON_SCRIPT"
    return 1
fi

source "$COMMON_SCRIPT"

# Download and install fonts
main() {
    # Download fonts to temp directory
    local fonts_source
    fonts_source=$(download_github_fonts)
    local download_status=$?
    
    if [[ $download_status -ne 0 ]]; then
        return 1
    fi
    
    # Get temp_dir from fonts_source path for cleanup
    local temp_dir=$(dirname "$fonts_source")
    
    # Install fonts (target auto-detected as ~/Library/Fonts on macOS)
    install_fonts "$fonts_source"
    local install_status=$?
    
    # Cleanup
    rm -rf "$temp_dir"
    
    return $install_status
}

main
