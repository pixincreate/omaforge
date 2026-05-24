#!/bin/bash

source "$RIG_INSTALL/helpers/logging.sh"

log_section "Web Applications"

# Ensure bin directory is in PATH for the session
export PATH="$RIG_PATH/bin:$PATH"

# ChatGPT (Incognito mode)
log_info "Installing ChatGPT web app (incognito)..."
rig-webapp-install "ChatGPT" \
  "https://chatgpt.com/" \
  "https://cdn.oaistatic.com/_next/static/media/apple-touch-icon.59f2e898.png" \
  "rig-launch-webapp https://chatgpt.com"

# Grok (Incognito mode)
log_info "Installing Grok web app (incognito)..."
rig-webapp-install "Grok" \
  "https://grok.com/" \
  "https://abs.twimg.com/responsive-web/client-web/icon-ios.77d25eba.png" \
  "rig-launch-webapp https://grok.com"

log_success "Web applications installed"
