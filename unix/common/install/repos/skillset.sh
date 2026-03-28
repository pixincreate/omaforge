#!/bin/bash
set -euo pipefail

SKILLSET_REPO="git@github.com:pixincreate/skillset"
SKILLSET_DIR="$HOME/dev/scripts/skillset"
OMAFORGE_SKILL_SOURCE="$OMAFORGE_PATH/default/omaforge-skill"

ensure_skillset_repo() {
  if [[ -d "$SKILLSET_DIR/.git" ]]; then
    log_info "Skillset repo already present at: $SKILLSET_DIR"
  else
    mkdir -p "$(dirname "$SKILLSET_DIR")"
    log_info "Cloning skillset repo to: $SKILLSET_DIR"
    if git clone "$SKILLSET_REPO" "$SKILLSET_DIR"; then
      log_success "Skillset repo cloned"
    else
      log_error "Failed to clone skillset repo"
      return 1
    fi
  fi
}

install_omaforge_skill() {
  local target_link="$SKILLSET_DIR/skills/omaforge"

  mkdir -p "$(dirname "$target_link")"

  if [[ -L "$target_link" ]]; then
    local current_target
    current_target=$(readlink "$target_link")

    if [[ "$current_target" == "$OMAFORGE_SKILL_SOURCE" ]]; then
      log_info "Omaforge skill symlink already correct"
      return 0
    else
      log_info "Removing stale symlink: $target_link"
      rm "$target_link"
    fi
  elif [[ -e "$target_link" ]]; then
    log_info "Removing existing file/dir: $target_link"
    rm -rf "$target_link"
  fi

  log_info "Symlinking omaforge skill to skillset repo"
  ln -s "$OMAFORGE_SKILL_SOURCE" "$target_link"
  log_success "Omaforge skill symlinked"
}

ensure_capsync_config() {
  if [[ -f "$HOME/.config/capsync/config.toml" ]]; then
    log_info "Capsync config already present"
  else
    log_info "Initializing capsync configuration"
    capsync init
  fi
}

sync_skills() {
  log_info "Syncing skills with capsync"
  if capsync sync; then
    log_success "Skills synced successfully"
  else
    log_error "Failed to sync skills"
    return 1
  fi
}

log_section "Skillset Setup"

ensure_skillset_repo
install_omaforge_skill
ensure_capsync_config
sync_skills

log_success "Skillset setup completed"
