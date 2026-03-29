#!/bin/bash

log_info "Setting up Ghostty configuration"

GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
GHOSTTY_OS_DIR="$GHOSTTY_CONFIG_DIR/os"
GHOSTTY_THEMES_DIR="$GHOSTTY_CONFIG_DIR/themes"

# Download themes on Linux only (brew includes themes on macOS)
if [[ "$(uname)" == "Linux" ]]; then
    if [[ ! -d "$GHOSTTY_THEMES_DIR" ]] || [[ -z "$(ls -A "$GHOSTTY_THEMES_DIR" 2>/dev/null)" ]]; then
        log_info "Downloading Ghostty themes..."

        tmpdir=$(mktemp -d)
        if git clone --depth 1 --filter=blob:none --sparse https://github.com/mbadolato/iTerm2-Color-Schemes.git "$tmpdir"; then
            cd "$tmpdir"
            git sparse-checkout set ghostty
            mkdir -p "$GHOSTTY_THEMES_DIR"
            rsync -a ghostty/ "$GHOSTTY_THEMES_DIR/"
            cd "$HOME"
            rm -rf "$tmpdir"
            log_success "Ghostty themes downloaded"
        else
            log_warning "Failed to download Ghostty themes"
        fi
    else
        log_info "Ghostty themes already present"
    fi
fi

# Set up OS-specific config symlink
if [ ! -d "$GHOSTTY_OS_DIR" ]; then
    log_warning "Ghostty OS config directory not found at $GHOSTTY_OS_DIR"
    exit 0
fi

if [ -f "$GHOSTTY_OS_DIR/current.conf" ]; then
    log_info "Ghostty OS config already linked"
    exit 0
fi

os_config=""
if [ "$(uname)" = "Darwin" ]; then
    os_config="macos.conf"
elif [ "$(uname)" = "Linux" ]; then
    os_config="linux.conf"
else
    log_warning "Unknown OS, skipping Ghostty config linking"
    exit 0
fi

ln -sf "$os_config" "$GHOSTTY_OS_DIR/current.conf"
log_success "Linked Ghostty config"
