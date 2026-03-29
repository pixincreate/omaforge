#!/bin/bash

source "${OMAFORGE_INSTALL:-"$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"}/helpers/all.sh"

configure_hibernation() {
  local hibernation_config
  hibernation_config=$(get_config '.hibernation.enabled')

  if [[ $hibernation_config != "true" ]]; then
    if ! confirm "Enable hibernation support?"; then
      log_info "Hibernation setup skipped"
      return 0
    fi
  fi

  log_info "Configuring hibernation support"

  if [[ ! -d /sys/firmware/efi ]]; then
    log_error "EFI not detected - hibernation requires EFI system"
    return 1
  fi

  if ! mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled"; then
    log_warning "Secure Boot not enabled - hibernation may have issues"
    log_info "Continuing with encrypted swap setup anyway"
  fi

  setup_encrypted_swap
}

setup_encrypted_swap() {
  local mem_total_human
  mem_total_human=$(free --human | grep Mem | awk '{print $2}')

  log_info "RAM size: ${mem_total_human}"
  log_info "You need ${mem_total_human} of unallocated disk space"

  lsblk
  echo
  read -r -p "Enter swap partition device (e.g., /dev/nvme0n1p3): " swap_device

  if [[ ! "$swap_device" =~ ^/dev/[a-zA-Z0-9_]+$ ]]; then
    log_error "Invalid device path format: $swap_device"
    return 1
  fi

  if [[ ! -b "$swap_device" ]]; then
    log_error "Device $swap_device not found"
    return 1
  fi

  log_warning "This will erase all data on $swap_device"
  if ! confirm "Encrypt $swap_device for hibernation?"; then
    log_info "Hibernation setup cancelled"
    return 0
  fi

  local luks_name="swap" luks_uuid

  log_info "Creating LUKS container"
  if ! sudo cryptsetup luksFormat --type luks2 "$swap_device"; then
    log_error "Failed to create LUKS container"
    return 1
  fi

  log_info "Opening LUKS container"
  if ! sudo cryptsetup open "$swap_device" "$luks_name"; then
    log_error "Failed to open LUKS container"
    return 1
  fi

  luks_uuid=$(cryptsetup luksUUID "$swap_device")

  log_info "Creating swap"
  if ! sudo mkswap "/dev/mapper/${luks_name}"; then
    log_error "Failed to create swap"
    sudo cryptsetup close "$luks_name" 2>/dev/null || true
    return 1
  fi

  if ! grep -q "^${luks_name} " /etc/crypttab 2>/dev/null; then
    printf "%s UUID=%s /dev/urandom swap\n" "$luks_name" "$luks_uuid" | sudo tee -a /etc/crypttab >/dev/null
  fi

  if [[ -f /etc/fstab ]]; then
    sudo cp -a /etc/fstab "/etc/fstab.$(date +%Y%m%d%H%M%S).back"
  fi

  if ! grep -q "/dev/mapper/${luks_name}" /etc/fstab; then
    printf "\n# Encrypted swap for hibernation\n/dev/mapper/%s none swap pri=10 0 0\n" "$luks_name" | sudo tee -a /etc/fstab >/dev/null
  fi

  sudo swapon "/dev/mapper/${luks_name}"

  if cmd_exists grubby; then
    sudo grubby --update-kernel=ALL --remove-args="resume resume_offset"
    sudo grubby --update-kernel=ALL --args="resume=/dev/mapper/${luks_name}"
  else
    log_warning "grubby not available"
    log_info "Add to kernel cmdline: resume=/dev/mapper/${luks_name}"
  fi

  local dracut_resume_conf="/etc/dracut.conf.d/99-resume.conf"
  if [[ ! -f "$dracut_resume_conf" ]] || ! grep -q "add_dracutmodules" "$dracut_resume_conf" 2>/dev/null; then
    echo 'add_dracutmodules+=" resume "' | sudo tee "$dracut_resume_conf" >/dev/null
  fi

  sudo dracut -f

  log_success "Hibernation configured"
  log_info "Test with: systemctl hibernate"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  configure_hibernation
fi
