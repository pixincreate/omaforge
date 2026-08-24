#!/bin/bash
# Dotfiles repo checks. The repo path is derived from config.json
# (dotfiles.stow_source), so it is not hardcoded. Skipped gracefully when
# the dotfiles repo is absent (e.g. CI).

DOTFILES_STOW="$(jq -r '.dotfiles.stow_source' "$RIG_REPO/unix/fedora/config.json" 2>/dev/null || true)"
DOTFILES_STOW="${DOTFILES_STOW/#\~/$HOME}"
DOTFILES_REPO="$(dirname "$DOTFILES_STOW")"

if [[ ! -d "$DOTFILES_REPO" ]]; then
  echo -e "  ${TC_YELLOW}⚠${TC_RESET} dotfiles repo not found at $DOTFILES_REPO — skipping dotfiles-repo checks"
  return 0
fi

section "omo removal in dotfiles repo"

assert_failure "opencode.jsonc has no oh-my-openagent plugin" \
  grep -q 'oh-my-openagent' "$DOTFILES_REPO/home/config/.config/opencode/opencode.jsonc"

assert_failure ".zshenv has no OMO_ vars" \
  grep -q 'OMO_' "$DOTFILES_REPO/home/zsh/.zsh/.zshenv"

assert_failure "dotfiles home/omo dir absent" \
  test -d "$DOTFILES_REPO/home/omo"

section "dotfiles repo config files"

assert_success "opencode.jsonc exists" \
  test -f "$DOTFILES_REPO/home/config/.config/opencode/opencode.jsonc"

assert_success ".zshenv exists" \
  test -f "$DOTFILES_REPO/home/zsh/.zsh/.zshenv"
