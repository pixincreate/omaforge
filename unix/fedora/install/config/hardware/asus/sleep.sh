#!/bin/bash

source "$OMAFORGE_INSTALL/helpers/all.sh"

if ! sudo dmidecode -s system-manufacturer 2>/dev/null | grep -qi asus; then
  exit 0
fi

asus_dir="$OMAFORGE_INSTALL/config/hardware/asus"

if [[ ! -d "$asus_dir/system-sleep" ]]; then
  exit 0
fi

log_info "Installing ASUS sleep hooks"

for script in "$asus_dir/system-sleep"/*; do
  [[ -f "$script" ]] || continue
  _target="/usr/lib/systemd/system-sleep/$(basename "$script")"
  if [[ -f "$_target" ]] && cmp -s "$script" "$_target"; then
    log_info "Already installed: $(basename "$script")"
  else
    sudo cp "$script" "$_target"
    sudo chmod 755 "$_target"
    log_info "Installed: $(basename "$script")"
  fi
done

log_success "ASUS sleep hooks installed"
