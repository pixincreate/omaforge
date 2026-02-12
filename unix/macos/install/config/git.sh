#!/bin/bash
# Git and SSH configuration for macOS

echo "Configuring Git and SSH"

# Get configuration from macOS config.json
git_name=$(get_config '.git.user_name')
git_email=$(get_config '.git.user_email')
ssh_dir=$(expand_path "$(get_config '.directories.ssh')")
gitconfig_local="$HOME/.config/gitconfig/.gitconfig.local"

# Create .gitconfig.local with proper include structure
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    log_info "Creating ~/.gitconfig.local with include directives"
    cat > "$HOME/.gitconfig.local" <<EOF
[include]
    path = "~/.config/gitconfig/.gitconfig"
    path = "~/.config/gitconfig/.gitconfig.local"
EOF
    log_success "Created ~/.gitconfig.local"
fi

# Source common git setup
COMMON_SCRIPT="$OMAFORGE_PATH/../common/config/git.sh"

if [[ ! -f "$COMMON_SCRIPT" ]]; then
    log_error "Common git setup script not found: $COMMON_SCRIPT"
    return 1
fi

source "$COMMON_SCRIPT"

# Run setup with macOS-specific config values
setup_git "$git_name" "$git_email" "$ssh_dir" "$gitconfig_local"

log_success "Git and SSH configuration completed"
