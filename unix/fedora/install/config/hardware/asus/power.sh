#!/bin/bash

source "$OMAFORGE_INSTALL/helpers/all.sh"

if ! sudo dmidecode -s system-manufacturer 2>/dev/null | grep -qi asus; then
  exit 0
fi

if [[ ! -f /sys/firmware/acpi/platform_profile_choices ]]; then
  exit 0
fi

if ! grep -q "quiet" /sys/firmware/acpi/platform_profile_choices 2>/dev/null; then
  exit 0
fi

log_info "Configuring ASUS power profiles"

tuned_controller=$(find /usr/lib/python3.*/site-packages/tuned/ppd/controller.py 2>/dev/null | head -1)

if [[ -z "$tuned_controller" ]] || [[ ! -f "$tuned_controller" ]]; then
  log_warning "tuned-ppd not found"
  exit 0
fi

if grep -q '"quiet": PPD_POWER_SAVER' "$tuned_controller"; then
  log_info "tuned-ppd already patched"
else
  sudo cp "$tuned_controller" "${tuned_controller}.backup"
  sudo sed -i '/PLATFORM_PROFILE_MAPPING = {/,/}/s/"low-power": PPD_POWER_SAVER,/"low-power": PPD_POWER_SAVER,\n    "quiet": PPD_POWER_SAVER,/' "$tuned_controller"

  if grep -q '"quiet": PPD_POWER_SAVER' "$tuned_controller"; then
    log_success "tuned-ppd patched"
    sudo systemctl restart tuned-ppd 2>/dev/null || true
  fi
fi

real_user="${SUDO_USER:-$USER}"

if [[ "$real_user" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  sudo tee /etc/systemd/system/asus-profile-notify@.service >/dev/null <<'EOF'
[Unit]
Description=ASUS Profile Change Notification for %i
[Service]
Type=oneshot
User=%i
Environment="DISPLAY=:0"
ExecStart=%h/.local/bin/asus-profile-notify.sh
EOF

  sudo tee /etc/udev/rules.d/99-asus-profile-toast.rules >/dev/null <<EOF
KERNEL=="platform-profile-*", SUBSYSTEM=="platform-profile", ACTION=="change", TAG+="systemd", ENV{SYSTEMD_USER}="$real_user", ENV{SYSTEMD_WANTS}="asus-profile-notify@$real_user.service"
EOF

  sudo udevadm control --reload-rules
  sudo systemctl daemon-reload
  log_success "ASUS notifications configured"
fi

log_success "ASUS power configuration complete"
