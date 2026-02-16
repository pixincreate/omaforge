#!/bin/bash

set -e

# Source platform detection helper
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers/platform.sh"

install_fonts() {
    local fonts_source="${1:-$HOME/.dotfiles/fonts}"
    local fonts_target="${2:-}"

    echo "Installing fonts"

    if [[ -z "$fonts_target" ]]; then
        local platform=$(detect_platform)
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

    # Count fonts
    local font_count=$(find "$fonts_source" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.ttc" -o -name "*.TTF" -o -name "*.OTF" -o -name "*.TTC" \) 2>/dev/null | wc -l)

    if [[ $font_count -eq 0 ]]; then
        echo "[WARNING] No fonts found in: $fonts_source"
        return 0
    fi

    echo "[INFO] Found $font_count fonts in: $fonts_source"
    echo "[INFO] Installing to: $fonts_target"

    local installed=0
    local skipped=0

    while IFS= read -r font; do
        local font_name=$(basename "$font")
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

    local platform=$(detect_platform)
    if command -v fc-cache &>/dev/null; then
        fc-cache -f "$fonts_target"
        echo "[SUCCESS] Font cache rebuilt"
    elif [[ "$platform" == "macos" ]]; then
        # macOS doesn't need manual cache rebuild
        echo "[INFO] macOS will rebuild font cache automatically"
    else
        echo "[WARNING] fc-cache not found, fonts may not be immediately available"
        echo "[INFO] Install fontconfig: sudo dnf install fontconfig (Fedora) or sudo apt install fontconfig (Debian)"
    fi

    echo "[SUCCESS] Font installation completed"
    echo "[INFO] Installed: $installed, Skipped: $skipped"
}

# Function to get latest release tag for a GitHub repo
# Usage: get_latest_release_tag "owner/repo"
# Returns: Latest release tag (e.g., "v34.1.0")
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

# Function to get latest release download URL for a GitHub repo
# Usage: get_latest_release_url "owner/repo" "asset_pattern"
# Returns: Download URL for the matching asset
get_latest_release_url() {
    local repo="$1"
    local asset_pattern="$2"
    
    # Use GitHub API to get latest release
    local api_url="https://api.github.com/repos/$repo/releases/latest"
    local download_url
    
    # Try to get the browser_download_url for matching asset
    download_url=$(curl -sL "$api_url" | grep -o '"browser_download_url": "[^"]*' | grep "$asset_pattern" | head -1 | sed 's/"browser_download_url": "//')
    
    if [[ -n "$download_url" ]]; then
        echo "$download_url"
        return 0
    else
        return 1
    fi
}

# Helper function to download and extract a font package
# Usage: download_font_package "repo" "asset_pattern" "url_template" "temp_dir" "fonts_source_dir" "font_name"
# Returns: Number of fonts extracted via stdout, logs to stderr
download_font_package() {
    local repo="$1"
    local asset_pattern="$2"
    local url_template="$3"  # Template with {tag} and {version} placeholders
    local temp_dir="$4"
    local fonts_source="$5"
    local font_name="$6"
    
    echo >&2 "[INFO] Fetching latest $font_name release..."
    
    local download_url
    download_url=$(get_latest_release_url "$repo" "$asset_pattern")
    
    if [[ -z "$download_url" && -n "$url_template" ]]; then
        # Construct URL from latest release tag
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

# Download fonts from GitHub releases
# Downloads Iosevka, IosevkaAile, JetBrains Mono, and Intel One Mono
# Returns: Path to directory containing downloaded fonts (caller must cleanup)
download_github_fonts() {
    local temp_dir=$(mktemp -d)
    local fonts_source="$temp_dir/fonts"
    mkdir -p "$fonts_source"
    local total_downloaded=0
    
    echo >&2 "[INFO] Downloading fonts from GitHub releases..."
    
    # Download Iosevka (SGr variant)
    local iosevka_count
    iosevka_count=$(download_font_package \
        "be5invis/Iosevka" \
        "PkgTTC-SGr-Iosevka" \
        "https://github.com/be5invis/Iosevka/releases/download/{tag}/PkgTTC-SGr-Iosevka-{version}.zip" \
        "$temp_dir" \
        "$fonts_source" \
        "Iosevka")
    total_downloaded=$((total_downloaded + iosevka_count))
    
    # Download IosevkaAile
    local iosevka_aile_count
    iosevka_aile_count=$(download_font_package \
        "be5invis/Iosevka" \
        "PkgTTC-IosevkaAile" \
        "https://github.com/be5invis/Iosevka/releases/download/{tag}/PkgTTC-IosevkaAile-{version}.zip" \
        "$temp_dir" \
        "$fonts_source" \
        "IosevkaAile")
    total_downloaded=$((total_downloaded + iosevka_aile_count))
    
    # Download Iosevka (standard variant)
    local iosevka_std_count
    iosevka_std_count=$(download_font_package \
        "be5invis/Iosevka" \
        "PkgTTC-Iosevka-[0-9]" \
        "https://github.com/be5invis/Iosevka/releases/download/{tag}/PkgTTC-Iosevka-{version}.zip" \
        "$temp_dir" \
        "$fonts_source" \
        "Iosevka Standard")
    total_downloaded=$((total_downloaded + iosevka_std_count))

    # Download IosevkaTerm (SGr variant)
    local iosevka_term_count
    iosevka_term_count=$(download_font_package \
        "be5invis/Iosevka" \
        "PkgTTC-SGr-IosevkaTerm" \
        "https://github.com/be5invis/Iosevka/releases/download/{tag}/PkgTTC-SGr-IosevkaTerm-{version}.zip" \
        "$temp_dir" \
        "$fonts_source" \
        "IosevkaTerm")
    total_downloaded=$((total_downloaded + iosevka_term_count))

    # Download JetBrains Mono
    local jetbrains_count
    jetbrains_count=$(download_font_package \
        "JetBrains/JetBrainsMono" \
        "JetBrainsMono" \
        "https://github.com/JetBrains/JetBrainsMono/releases/download/{tag}/JetBrainsMono-{version}.zip" \
        "$temp_dir" \
        "$fonts_source" \
        "JetBrains Mono")
    total_downloaded=$((total_downloaded + jetbrains_count))
    
    # Download Intel One Mono
    local intel_count
    intel_count=$(download_font_package \
        "intel/intel-one-mono" \
        "ttf" \
        "https://github.com/intel/intel-one-mono/releases/download/{tag}/ttf.zip" \
        "$temp_dir" \
        "$fonts_source" \
        "Intel One Mono")
    total_downloaded=$((total_downloaded + intel_count))
    
    echo >&2 "[INFO] Total fonts downloaded: $total_downloaded"
    
    if [[ $total_downloaded -eq 0 ]]; then
        echo >&2 "[ERROR] No fonts were downloaded"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Return the fonts source directory path
    echo "$fonts_source"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_fonts "$@"
fi
