#!/bin/bash

source "$OMAFORGE_INSTALL/helpers/all.sh"

if ! sudo dmidecode -s system-manufacturer 2>/dev/null | grep -qi asus; then
  exit 0
fi

if [[ -f /etc/modprobe.d/asus-audio.conf ]]; then
  log_info "ASUS audio already configured"
  exit 0
fi

log_info "Configuring ASUS audio"
echo 'options snd_hda_intel model=alc256-asus' | sudo tee /etc/modprobe.d/asus-audio.conf >/dev/null
log_success "ASUS audio configured (reboot required)"
