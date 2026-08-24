#!/bin/bash
section "ZSH generator (zsh.sh)"

assert_success "zsh.sh has boundary marker" \
  grep -q 'rig manages everything above this line' "$RIG_REPO/unix/common/dotfiles/zsh.sh"

assert_success "zsh.sh skips existing user-owned local.zsh" \
  grep -qF 'leaving it untouched (user-owned)' "$RIG_REPO/unix/common/dotfiles/zsh.sh"

assert_bash_syntax "zsh.sh" "$RIG_REPO/unix/common/dotfiles/zsh.sh"
if command -v shellcheck &>/dev/null; then
  assert_shellcheck "zsh.sh" "$RIG_REPO/unix/common/dotfiles/zsh.sh"
fi

section "Migrations are valid and self-contained"

for m in "$RIG_REPO"/unix/fedora/migrations/*.sh; do
  name=$(basename "$m")
  assert_bash_syntax "migration $name" "$m"
  if command -v shellcheck &>/dev/null; then
    assert_shellcheck "migration $name" "$m"
  fi
  if grep -q 'RIG_PATH' "$m"; then
    assert_success "migration $name guards unset RIG_PATH" \
      grep -qF 'RIG_PATH:-' "$m"
  fi
  if grep -q 'setup_zsh' "$m"; then
    assert_success "migration $name regenerates local.zsh via setup_zsh" \
      grep -qF 'setup_zsh' "$m"
  fi
  assert_failure "migration $name leaves .additionals.zsh untouched" \
    grep -E '(rm|mv).*additionals' "$m"
done

section "opencode via COPR (not npm)"

assert_success "opencode in fedora development packages" \
  grep -qx 'opencode' "$RIG_REPO/unix/fedora/packages/development.packages"

assert_success "sureclaw/opencode COPR configured" \
  grep -q 'sureclaw/opencode' "$RIG_REPO/unix/fedora/config.json"

assert_failure "opencode absent from npm packages" \
  grep -q 'opencode' "$RIG_REPO/unix/fedora/packages/npm.packages"

section "Package cleanup (ollama removed, replacements present)"

assert_failure "ollama absent from fedora packages" \
  grep -rq '^ollama$' "$RIG_REPO/unix/fedora/packages/"

assert_failure "ollama absent from macos brew packages" \
  grep -rq '^ollama$' "$RIG_REPO/unix/macos/packages/"

assert_success "llama-cpp present in fedora development packages" \
  grep -qx 'llama-cpp' "$RIG_REPO/unix/fedora/packages/development.packages"

assert_success "age present in fedora tools packages" \
  grep -qx 'age' "$RIG_REPO/unix/fedora/packages/tools.packages"

assert_success "rofimoji present in fedora tools packages" \
  grep -qx 'rofimoji' "$RIG_REPO/unix/fedora/packages/tools.packages"

assert_success "wtype present in fedora tools packages" \
  grep -qx 'wtype' "$RIG_REPO/unix/fedora/packages/tools.packages"

assert_success "fuzzel present in fedora tools packages" \
  grep -qx 'fuzzel' "$RIG_REPO/unix/fedora/packages/tools.packages"

assert_success "tesseract present in fedora tools packages" \
  grep -qx 'tesseract' "$RIG_REPO/unix/fedora/packages/tools.packages"

assert_success "llama.cpp present in macos brew packages" \
  grep -qx 'llama.cpp' "$RIG_REPO/unix/macos/packages/brew.packages"

assert_success "age present in macos brew packages" \
  grep -qx 'age' "$RIG_REPO/unix/macos/packages/brew.packages"

section "Fedora COPR (llama.cpp)"

assert_success "sneed/llama-cpp-vulkan COPR configured" \
  grep -q 'sneed/llama-cpp-vulkan' "$RIG_REPO/unix/fedora/config.json"

section "New rig CLI scripts"

assert_success "rig-llama has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/common/libexec/rig-llama"
assert_success "rig-ocr has summary" grep -q 'rig:summary=' "$RIG_REPO/unix/common/libexec/rig-ocr"
assert_success "rig-llama has usage" grep -q 'rig:usage=' "$RIG_REPO/unix/common/libexec/rig-llama"
assert_success "rig-ocr has usage" grep -q 'rig:usage=' "$RIG_REPO/unix/common/libexec/rig-ocr"
