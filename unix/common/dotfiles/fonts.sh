#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers/platform.sh"

# Font definitions: repo|asset_pattern|url_template|name
# url_template uses {tag} and {version} placeholders
FONTS=(
    "be5invis/Iosevka|PkgTTC-SGr-Iosevka|https://github.com/be5invis/Iosevka/releases/download/{tag}/PkgTTC-SGr-Iosevka-{version}.zip|Iosevka"
    "be5invis/Iosevka|PkgTTC-IosevkaAile|https://github.com/be5invis/Iosevka/releases/download/{tag}/PkgTTC-IosevkaAile-{version}.zip|IosevkaAile"
    "be5invis/Iosevka|PkgTTC-Iosevka-[0-9]|https://github.com/be5invis/Iosevka/releases/download/{tag}/PkgTTC-Iosevka-{version}.zip|Iosevka Standard"
    "be5invis/Iosevka|PkgTTC-SGr-IosevkaTerm|https://github.com/be5invis/Iosevka/releases/download/{tag}/PkgTTC-SGr-IosevkaTerm-{version}.zip|IosevkaTerm"
    "JetBrains/JetBrainsMono|JetBrainsMono|https://github.com/JetBrains/JetBrainsMono/releases/download/{tag}/JetBrainsMono-{version}.zip|JetBrains Mono"
    "intel/intel-one-mono|ttf|https://github.com/intel/intel-one-mono/releases/download/{tag}/ttf.zip|Intel One Mono"
    "vercel/geist-font|geist-font|https://github.com/vercel/geist-font/releases/download/{tag}/geist-font-v{version}.zip|Geist"
)

# Nerd Fonts with direct URLs (not GitHub releases)
NERD_FONTS=(
    "CaskaydiaCove|https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip"
    "Meslo|https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.zip"
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

get_latest_release_tag() {
    local repo="$1"
    local api_url="https://api.github.com/repos/$repo/releases/latest"
    local tag

    tag=$(curl -sL "$api_url" | grep -o '"tag_name": "[^"]*' | head -1 | sed 's/"tag_name": "//')

    if [[ -n "$tag" ]]; then
        echo "$tag"
        return 0
    else
        return 1
    fi
}

get_latest_release_url() {
    local repo="$1"
    local asset_pattern="$2"

    local api_url="https://api.github.com/repos/$repo/releases/latest"
    local download_url

    download_url=$(curl -sL "$api_url" | grep -o '"browser_download_url": "[^"]*' | grep "$asset_pattern" | head -1 | sed 's/"browser_download_url": "//')

    if [[ -n "$download_url" ]]; then
        echo "$download_url"
        return 0
    else
        return 1
    fi
}

download_font_package() {
    local repo="$1"
    local asset_pattern="$2"
    local url_template="$3"
    local temp_dir="$4"
    local fonts_source="$5"
    local font_name="$6"

    echo >&2 "[INFO] Fetching latest $font_name release..."

    local download_url
    download_url=$(get_latest_release_url "$repo" "$asset_pattern")

    if [[ -z "$download_url" && -n "$url_template" ]]; then
        local tag
        tag=$(get_latest_release_tag "$repo")
        if [[ -n "$tag" ]]; then
            local version="${tag#v}"
            download_url="${url_template//\{tag\}/$tag}"
            download_url="${download_url//\{version\}/$version}"
            echo >&2 "[INFO] Constructed $font_name URL from tag: $tag"
        fi
    fi

    if [[ -z "$download_url" ]]; then
        echo >&2 "[ERROR] Could not determine $font_name download URL"
        echo "0"
        return 1
    fi

    echo >&2 "[INFO] Downloading $font_name from: $download_url"
    local zip_file="$temp_dir/${font_name// /_}.zip"
    local extract_dir="$temp_dir/${font_name// /_}"

    if curl -sL -o "$zip_file" "$download_url"; then
        echo >&2 "[SUCCESS] Downloaded $font_name"
        unzip -q "$zip_file" -d "$extract_dir" 2>/dev/null || true

        local font_count=0
        while IFS= read -r font; do
            cp "$font" "$fonts_source/" 2>/dev/null
            font_count=$((font_count + 1))
        done < <(find "$extract_dir" -type f \( -name "*.ttf" -o -name "*.TTF" -o -name "*.ttc" -o -name "*.TTC" -o -name "*.otf" -o -name "*.OTF" \) 2>/dev/null)

        echo >&2 "[INFO] Extracted $font_count $font_name fonts"
        echo "$font_count"
        return 0
    else
        echo >&2 "[WARNING] Failed to download $font_name"
        echo "0"
        return 1
    fi
}

fonts_already_installed() {
    local fonts_target="${1:-$HOME/.local/share/fonts}"
    local -a font_names=()

    for font_def in "${FONTS[@]}" "${NERD_FONTS[@]}"; do
        local name="${font_def%%|*}"
        font_names+=("$name")
    done

    local found_families=0
    for family in "${font_names[@]}"; do
        if find "$fonts_target" -type f \( -name "*${family}*" -o -name "*${family,,}*" \) -print -quit 2>/dev/null | grep -q .; then
            found_families=$((found_families + 1))
        fi
    done

    local total_families=$((${#FONTS[@]} + ${#NERD_FONTS[@]}))
    local min_required=$((total_families * 70 / 100))

    if (( found_families >= min_required )); then
        return 0
    else
        return 1
    fi
}

download_github_fonts() {
    local temp_dir
    temp_dir=$(mktemp -d)
    local fonts_source="$temp_dir/fonts"
    mkdir -p "$fonts_source"
    local total_downloaded=0

    local fonts_target="$HOME/.local/share/fonts"
    if fonts_already_installed "$fonts_target"; then
        echo >&2 "[INFO] Fonts already installed at $fonts_target"
        echo >&2 "[INFO] Skipping download. Use --force to re-download."
        rm -rf "$temp_dir"
        echo ""
        return 0
    fi

    echo >&2 "[INFO] Downloading fonts from GitHub releases..."

    for font_def in "${FONTS[@]}"; do
        IFS='|' read -r repo asset_pattern url_template font_name <<< "$font_def"

        local count
        count=$(download_font_package "$repo" "$asset_pattern" "$url_template" "$temp_dir" "$fonts_source" "$font_name")
        total_downloaded=$((total_downloaded + count))
    done

    for font_def in "${NERD_FONTS[@]}"; do
        IFS='|' read -r font_name url <<< "$font_def"

        echo >&2 "[INFO] Downloading $font_name Nerd Font..."
        local zip_file="$temp_dir/${font_name}.zip"

        if curl -sL -o "$zip_file" "$url"; then
            unzip -q "$zip_file" -d "$temp_dir/$font_name" 2>/dev/null || true
            local count=0
            while IFS= read -r font; do
                cp "$font" "$fonts_source/" 2>/dev/null
                count=$((count + 1))
            done < <(find "$temp_dir/$font_name" -type f \( -name "*.ttf" -o -name "*.otf" \) 2>/dev/null)
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

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_fonts "$@"
fi
