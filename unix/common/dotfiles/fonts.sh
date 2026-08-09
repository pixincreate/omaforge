#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers/platform.sh"

# Nerd Fonts from ryanoasis/nerd-fonts GitHub releases.
# Format: name|download_url|filter
#   filter = "nomono" to skip the *NerdFontMono* variant files, empty for all.
# Version comes from config.json (.fonts.nerd_fonts_version); falls back to a
# pinned default for the rig fonts CLI, which runs without RIG_CONFIG set.
NERD_FONTS_VERSION="v3.5.0"
if [[ -n "${RIG_CONFIG:-}" && -f "$RIG_CONFIG" ]] && command -v jq &>/dev/null; then
  NERD_FONTS_VERSION="$(jq -r '.fonts.nerd_fonts_version // "v3.5.0"' "$RIG_CONFIG" 2>/dev/null)"
fi
NERD_FONTS_BASE="https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONTS_VERSION}"
NERD_FONTS=(
  "AdwaitaMono|${NERD_FONTS_BASE}/AdwaitaMono.zip|"
  "CaskaydiaCove|${NERD_FONTS_BASE}/CascadiaCode.zip|nomono"
  "FiraCode|${NERD_FONTS_BASE}/FiraCode.zip|nomono"
  "JetBrainsMono|${NERD_FONTS_BASE}/JetBrainsMono.zip|"
  "Iosevka|${NERD_FONTS_BASE}/Iosevka.zip|"
  "Meslo|${NERD_FONTS_BASE}/Meslo.zip|"
)

install_fonts() {
  local fonts_source="${1:-$HOME/.dotfiles/fonts}"
  local fonts_target="${2:-}"

  echo "Installing fonts"

  if [[ -z "$fonts_target" ]]; then
    local platform
    platform=$(detect_platform)
    if [[ "$platform" == "macos" ]]; then
      fonts_target="$HOME/Library/Fonts"
    else
      fonts_target="$HOME/.local/share/fonts"
    fi
    echo "[INFO] Auto-detected fonts directory: $fonts_target"
  fi

  if [[ ! -d "$fonts_source" ]]; then
    echo "[ERROR] Fonts source directory not found: $fonts_source"
    return 1
  fi

  mkdir -p "$fonts_target"

  local font_count
  font_count=$(find "$fonts_source" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.ttc" -o -name "*.TTF" -o -name "*.OTF" -o -name "*.TTC" \) 2>/dev/null | wc -l)

  if [[ $font_count -eq 0 ]]; then
    echo "[WARNING] No fonts found in: $fonts_source"
    return 0
  fi

  echo "[INFO] Found $font_count fonts in: $fonts_source"
  echo "[INFO] Installing to: $fonts_target"

  local installed=0
  local skipped=0

  while IFS= read -r font; do
    local font_name
    font_name=$(basename "$font")
    local target_path="$fonts_target/$font_name"

    if [[ -f "$target_path" ]]; then
      echo "[INFO] Already installed: $font_name"
      skipped=$((skipped + 1))
    else
      if cp "$font" "$target_path" 2>/dev/null; then
        echo "[SUCCESS] Installed: $font_name"
        installed=$((installed + 1))
      else
        echo "[WARNING] Failed to install: $font_name"
      fi
    fi
  done < <(find "$fonts_source" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.ttc" -o -name "*.TTF" -o -name "*.OTF" -o -name "*.TTC" \) 2>/dev/null)

  echo "[INFO] Rebuilding font cache"

  local platform
  platform=$(detect_platform)
  if command -v fc-cache &>/dev/null; then
    fc-cache -f "$fonts_target"
    echo "[SUCCESS] Font cache rebuilt"
  elif [[ "$platform" == "macos" ]]; then
    echo "[INFO] macOS will rebuild font cache automatically"
  else
    echo "[WARNING] fc-cache not found, fonts may not be immediately available"
    echo "[INFO] Install fontconfig: sudo dnf install fontconfig (Fedora) or sudo apt install fontconfig (Debian)"
  fi

  echo "[SUCCESS] Font installation completed"
  echo "[INFO] Installed: $installed, Skipped: $skipped"
}

fonts_already_installed() {
  local fonts_target="${1:-$HOME/.local/share/fonts}"
  local -a font_names=()

  for font_def in "${NERD_FONTS[@]}"; do
    local name="${font_def%%|*}"
    font_names+=("$name")
  done

  local found_families=0
  local total_families=${#font_names[@]}

  # Match only *NerdFont* files so plain (non-nerd) versions of a family do
  # not count as installed.
  for family in "${font_names[@]}"; do
    local search_pattern="${family// /}"
    search_pattern="${search_pattern//-/}"
    if find "$fonts_target" -type f -iname "*${search_pattern}*NerdFont*" -print -quit 2>/dev/null | grep -q .; then
      found_families=$((found_families + 1))
    fi
  done

  local min_required=$((total_families * 70 / 100))

  if (( found_families >= min_required )); then
    return 0
  else
    return 1
  fi
}

download_github_fonts() {
  local force=false
  [[ "${1:-}" == "--force" ]] && force=true

  local temp_dir
  temp_dir=$(mktemp -d)
  local fonts_source="$temp_dir/fonts"
  mkdir -p "$fonts_source"
  local total_downloaded=0

  local fonts_target="$HOME/.local/share/fonts"

  if ! $force; then
    echo >&2 "[INFO] Checking if fonts already installed at $fonts_target..."
    if fonts_already_installed "$fonts_target"; then
      echo >&2 "[INFO] Fonts already installed at $fonts_target"
      echo >&2 "[INFO] Skipping download. Use --force to re-download."
      rm -rf "$temp_dir"
      echo ""
      return 0
    fi
  fi

  echo >&2 "[INFO] Fonts not found or incomplete, downloading from nerd-fonts releases..."

  for font_def in "${NERD_FONTS[@]}"; do
    IFS='|' read -r font_name url filter <<< "$font_def"

    echo >&2 "[INFO] Downloading $font_name Nerd Font..."
    local zip_file="$temp_dir/${font_name}.zip"

    if curl -sL -o "$zip_file" "$url"; then
      unzip -q "$zip_file" -d "$temp_dir/$font_name" 2>/dev/null || true
      local count=0
      while IFS= read -r font; do
        # Skip the *Mono* variant files when the entry requests nomono.
        if [[ "$filter" == "nomono" ]] && [[ "$(basename "$font")" == *Mono* ]]; then
          continue
        fi
        cp "$font" "$fonts_source/" 2>/dev/null
        count=$((count + 1))
      done < <(find "$temp_dir/$font_name" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.ttc" -o -name "*.TTF" -o -name "*.OTF" -o -name "*.TTC" \) 2>/dev/null)
      echo >&2 "[INFO] Extracted $count $font_name fonts"
      total_downloaded=$((total_downloaded + count))
    else
      echo >&2 "[WARNING] Failed to download $font_name"
    fi
  done

  echo >&2 "[INFO] Total fonts downloaded: $total_downloaded"

  if [[ $total_downloaded -eq 0 ]]; then
    echo >&2 "[ERROR] No fonts were downloaded"
    rm -rf "$temp_dir"
    return 1
  fi

  echo "$fonts_source"
}
