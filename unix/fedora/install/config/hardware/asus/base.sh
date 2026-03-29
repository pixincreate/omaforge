#!/bin/bash

source "$OMAFORGE_INSTALL/helpers/all.sh"

if ! sudo dmidecode -s system-manufacturer 2>/dev/null | grep -qi asus; then
  log_info "Not an ASUS system"
  exit 0
fi

log_info "Installing ASUS packages"

mapfile -t packages < <(get_config_array '.hardware.asus.packages')

if [[ ${#packages[@]} -eq 0 ]]; then
  log_warning "No ASUS packages configured"
  exit 0
fi

if sudo dnf install -y "${packages[@]}"; then
  log_success "ASUS packages installed"
else
  log_error "Failed to install ASUS packages"
  exit 1
fi

sudo systemctl enable supergfxd.service 2>/dev/null || true
sudo systemctl start asusd 2>/dev/null || true

log_success "ASUS base configuration complete"
