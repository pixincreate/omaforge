#!/bin/bash
section "Common helpers syntax"
assert_bash_syntax "logging.sh" "$RIG_REPO/unix/common/helpers/logging.sh"
assert_bash_syntax "common.sh" "$RIG_REPO/unix/common/helpers/common.sh"
assert_bash_syntax "platform.sh" "$RIG_REPO/unix/common/helpers/platform.sh"

section "Common dotfiles syntax"
assert_bash_syntax "stow.sh" "$RIG_REPO/unix/common/dotfiles/stow.sh"
assert_bash_syntax "directories.sh" "$RIG_REPO/unix/common/dotfiles/directories.sh"
assert_bash_syntax "fonts.sh" "$RIG_REPO/unix/common/dotfiles/fonts.sh"
assert_bash_syntax "zsh.sh" "$RIG_REPO/unix/common/dotfiles/zsh.sh"

section "Common external scripts syntax"
for f in "$RIG_REPO/unix/common/install/external/"*.sh; do
    [[ -f "$f" ]] && assert_bash_syntax "$(basename "$f")" "$f"
done

section "Common bin scripts syntax"
for f in "$RIG_REPO/unix/common/bin/"*; do
    [[ -f "$f" ]] && assert_bash_syntax "$(basename "$f")" "$f"
done
