#!/bin/bash
set -eEuo pipefail

echo "Running migration: dotfile cleanup, ollama removal, llama.cpp/age/rofimoji"

# The `rig` dispatcher lives under bin/.

# Allow running this migration directly (rig-migrate sets RIG_PATH,
# but default to the parent of migrations/ when run standalone).
if [[ -z "${RIG_PATH:-}" ]]; then
  RIG_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
fi

# Marker appended to generated local.zsh: rig owns everything above,
# the user owns everything below and rig will never edit it.
MARKER="# rig manages everything above this line. Add your own config below — rig will never edit it."

# [1/3] Regenerate local.zsh; leave legacy .additionals.zsh untouched (user maintains it).
echo ""
echo "[1/3] Regenerating ZSH local.zsh and migrating gitconfig..."

# rm first so the generator recreates local.zsh (it early-returns if present)
rm -f "$HOME/.zsh/local.zsh"
source "$RIG_PATH/unix/common/dotfiles/zsh.sh"
setup_zsh

if ! grep --quiet --fixed-strings "$MARKER" "$HOME/.zsh/local.zsh" 2>/dev/null; then
  echo "$MARKER" >> "$HOME/.zsh/local.zsh"
fi

if [[ -f "$HOME/.gitconfig" ]]; then
  echo "[INFO] Removing legacy ~/.gitconfig so ~/.config/git/config takes effect"
  rm --force "$HOME/.gitconfig"
fi

if [[ -d "$HOME/.config/gitconfig" ]]; then
  echo "[INFO] Removing legacy ~/.config/gitconfig directory"
  rm -r "$HOME/.config/gitconfig"
fi

# Recreate ~/.config/git/config.local if the config/git installer phase never
# ran (it only runs via fedora-setup, never via migrate). Without it git has
# no identity: ~/.config/git/config includes this file.
gitconfig_local="$HOME/.config/git/config.local"
if [[ ! -f "$gitconfig_local" ]] && command -v jq >/dev/null 2>&1; then
  git_name=$(jq -r '.git.user_name // empty' "$RIG_PATH/unix/${RIG_PLATFORM:-fedora}/config.json")
  git_email=$(jq -r '.git.user_email // empty' "$RIG_PATH/unix/${RIG_PLATFORM:-fedora}/config.json")

  if [[ -n "$git_name" ]] && [[ -n "$git_email" ]]; then
    if [[ ! -f "$HOME/.ssh/id_ed25519_sign" ]]; then
      echo "[INFO] Generating SSH signing key"
      mkdir -p "$HOME/.ssh"
      ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519_sign" -N ""
    fi

    mkdir -p "$(dirname "$gitconfig_local")"
    cat > "$gitconfig_local" <<EOF
[user]
  name = $git_name
  email = $git_email
  signingkey = $HOME/.ssh/id_ed25519_sign.pub
EOF
    echo "[INFO] Recreated $gitconfig_local: $git_name <$git_email>"
  else
    echo "[WARNING] config.json has no .git.user_name/.git.user_email; run: ./unix/fedora/fedora-setup --only config/git"
  fi
fi

echo "[INFO] Restowing config and zsh packages via rig"
"$RIG_PATH/unix/${RIG_PLATFORM:-fedora}/bin/rig" stow config zsh

# [2/3] Remove ollama (replaced by llama.cpp)
echo ""
echo "[2/3] Removing ollama..."
if rpm -q ollama &>/dev/null; then
  sudo dnf remove -y ollama
else
  echo "[INFO] ollama is not installed"
fi

# [3/3] Enable llama.cpp COPR and install new packages
echo ""
echo "[3/3] Enabling sneed/llama-cpp-vulkan COPR and installing new packages..."

if ! dnf copr list 2>/dev/null | grep --quiet "sneed/llama-cpp-vulkan"; then
  sudo dnf copr enable -y sneed/llama-cpp-vulkan
else
  echo "[INFO] sneed/llama-cpp-vulkan COPR already enabled"
fi

"$RIG_PATH/unix/${RIG_PLATFORM:-fedora}/bin/rig" pkg-add tools age rofimoji wtype fuzzel tesseract tesseract-langpack-kan tesseract-langpack-hin mpv
"$RIG_PATH/unix/${RIG_PLATFORM:-fedora}/bin/rig" pkg-add development llama-cpp

# Install fonts (Nerd Fonts + Red Hat) via the shared fonts worker
echo ""
echo "Installing fonts..."
if [[ -d "$HOME/.local/share/fonts" ]] && compgen -G "$HOME/.local/share/fonts/*RedHat*" >/dev/null; then
  echo "[INFO] Red Hat fonts already present; skipping font install"
else
  "$RIG_PATH/unix/common/libexec/rig-fonts" install
fi

echo ""
echo "Configuring rofimoji (fuzzel selector, wtype typer)..."
rofimoji_rc="$HOME/.config/rofimoji.rc"
if [[ ! -f "$rofimoji_rc" ]]; then
  mkdir -p "$HOME/.config"
  cat > "$rofimoji_rc" <<'EOF'
selector = fuzzel
typer = wtype
clipboarder = wl-copy
EOF
  echo "[SUCCESS] Wrote $rofimoji_rc"
else
  echo "[INFO] $rofimoji_rc already exists; leaving it untouched"
fi

# Set up age key for encrypted local secrets
echo ""
echo "Setting up age key for encrypted secrets..."

age_key_dir="$HOME/.config/age"
age_key="$age_key_dir/key.txt"
age_pubkey="$age_key_dir/key.pub"

mkdir -p "$age_key_dir"
chmod 700 "$age_key_dir"

if [[ ! -f "$age_key" ]]; then
  echo "[INFO] Generating age keypair"
  age-keygen -o "$age_key" >/dev/null
  chmod 600 "$age_key"
  grep -E "^#? public key" "$age_key" | sed 's/.*: //' > "$age_pubkey"
  chmod 644 "$age_pubkey"
  echo "[SUCCESS] Age keypair created at $age_key"
else
  echo "[INFO] Age key already exists"
fi

# Migrate plaintext secrets into the encrypted env if an encrypted env does not yet exist
if [[ ! -f "$HOME/.zsh/.env.age" ]]; then
  plaintext_sources=("$HOME/.zsh/.env" "$HOME/dev/system.env" "$HOME/.additionals.env")
  chosen_source=""
  for src in "${plaintext_sources[@]}"; do
    if [[ -f "$src" ]]; then
      chosen_source="$src"
      break
    fi
  done

  if [[ -n "$chosen_source" ]]; then
    echo "[INFO] Encrypting $chosen_source to ~/.zsh/.env.age"
    age --encrypt --recipient "$(cat "$age_pubkey")" --output "$HOME/.zsh/.env.age" "$chosen_source"
    chmod 600 "$HOME/.zsh/.env.age"

    if age --decrypt --identity "$age_key" "$HOME/.zsh/.env.age" | diff --quiet - "$chosen_source" 2>/dev/null; then
      echo "[SUCCESS] Decrypt verified; removing plaintext source: $chosen_source"
      rm --force "$chosen_source"
    else
      echo "[WARNING] Decrypt did not match; keeping plaintext: $chosen_source"
    fi
  else
    echo "[INFO] No plaintext secrets file found to migrate"
    echo "[INFO] Create ~/.zsh/.env and run: age --encrypt -r \$(cat ~/.config/age/key.pub) -o ~/.zsh/.env.age ~/.zsh/.env"
  fi
else
  echo "[INFO] Encrypted env already exists at ~/.zsh/.env.age"
fi

echo ""
echo "[SUCCESS] Migration completed"
