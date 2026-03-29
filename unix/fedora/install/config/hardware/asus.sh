#!/bin/bash

source "$OMAFORGE_INSTALL/helpers/all.sh"

auto_detect=$(get_config '.hardware.asus.auto_detect')

if [[ $auto_detect != "true" ]]; then
  log_info "ASUS auto-detection disabled"
  exit 0
fi

if ! sudo dmidecode -s system-manufacturer 2>/dev/null | grep -qi asus; then
  log_info "Not an ASUS system"
  exit 0
fi

log_info "ASUS system detected"

asus_dir="$OMAFORGE_INSTALL/config/hardware/asus"

run_logged "$asus_dir/base.sh" || exit 1
run_logged "$asus_dir/audio.sh" || exit 1
run_logged "$asus_dir/power.sh" || exit 1
run_logged "$asus_dir/sleep.sh" || exit 1

log_success "ASUS configuration complete"
