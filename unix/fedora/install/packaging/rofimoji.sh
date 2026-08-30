#!/bin/bash

# shellcheck disable=SC1091 # $RIG_INSTALL is resolved at runtime by the installer
source "$RIG_INSTALL/helpers/logging.sh"

log_section "rofimoji"

mkdir -p "$HOME/.local/share/applications" "$HOME/.config/fuzzel"

rm -f "$HOME/.local/share/applications/rofimoji.desktop"
cat > "$HOME/.local/share/applications/rofimoji.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=rofimoji
Comment=Pick emojis, GIFs, and other Unicode characters
Exec=rofimoji
Icon=insert-smiley
Terminal=false
Categories=Utility;
EOF

rm -f "$HOME/.config/fuzzel/fuzzel.ini"
cat > "$HOME/.config/fuzzel/fuzzel.ini" <<'EOF'
# Fuzzel theme matching Fedora Dark (KDE system palette).
# Colors derived from kdeglobals [Colors:View]/[Colors:Selection].
[colors]
background=141618ff
text=fcfcfcff
prompt=fcfcfcff
input=fcfcfcff
match=6568b2ff
selection=4c4f83ff
selection-text=ffffffff
selection-match=6568b2ff
counter=fcfcfcff
counter-text=fcfcfcff
border=6568b2ff
scrollbar=6568b2ff
separator=4c4f83ff
EOF

if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 >/dev/null 2>&1 || true
fi

log_success "rofimoji launcher and fuzzel theme installed"