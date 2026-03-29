#!/bin/bash

log_info "Installing KDE Plasma configuration"

KDE_CONFIG_DIR="$OMAFORGE_INSTALL/config/kde"

if [[ ! -d "$KDE_CONFIG_DIR" ]]; then
  log_warning "KDE config directory not found: $KDE_CONFIG_DIR"
  return 0
fi

if [[ ! -d "$HOME/.config" ]]; then
  log_warning "$HOME/.config directory not found"
  return 0
fi

for file in "$KDE_CONFIG_DIR"/*; do
  [[ -f "$file" ]] || continue

  filename=$(basename "$file")
  target="$HOME/.config/$filename"

  if [[ -f "$target" ]]; then
    if ! cmp -s "$file" "$target"; then
      log_info "Backing up existing: $filename → ${filename}.bak"
      cp "$target" "${target}.bak"
    fi
  fi

  cp "$file" "$target"
  log_info "Installed: $filename"
done

log_success "KDE configuration installed"
