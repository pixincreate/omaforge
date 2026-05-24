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

  if [[ -L "$target" ]]; then
    current_target=$(readlink "$target")
    if [[ $current_target == "$file" ]]; then
      continue
    fi
    log_info "Updating symlink: $filename"
    ln -sf "$file" "$target"
  elif [[ -f "$target" ]]; then
    log_info "Backing up existing: $filename → ${filename}.bak"
    cp "$target" "${target}.bak"
    ln -sf "$file" "$target"
    log_info "Symlinked: $filename"
  else
    ln -sf "$file" "$target"
    log_info "Symlinked: $filename"
  fi
done

log_success "KDE configuration installed (symlinked)"
