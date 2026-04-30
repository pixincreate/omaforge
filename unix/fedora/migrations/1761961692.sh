#!/bin/bash
set -eEuo pipefail

echo "Running migration: Fix ASUS profile notification systemd service"

if ! sudo dmidecode -s system-manufacturer 2>/dev/null | grep -qi asus; then
    echo "[INFO] Not an ASUS system, skipping migration"
    exit 0
fi

REAL_USER="${SUDO_USER:-$USER}"

if [[ ! "$REAL_USER" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "[ERROR] Invalid username: $REAL_USER"
    exit 1
fi

user_systemd_dir="/home/$REAL_USER/.config/systemd/user"
user_service="$user_systemd_dir/asus-profile-notify@.service"

if [[ -f /etc/systemd/system/asus-profile-notify@.service ]]; then
    echo "[INFO] Removing old service from /etc/systemd/system/..."
    sudo rm -f /etc/systemd/system/asus-profile-notify@.service
fi

echo "[INFO] Creating user service in correct location..."
mkdir -p "$user_systemd_dir"

tee "$user_service" >/dev/null <<'EOF'
[Unit]
Description=ASUS Profile Change Notification for %i
[Service]
Type=oneshot
User=%i
Environment="DISPLAY=:0"
ExecStart=%h/.local/bin/asus-profile-notify.sh
EOF

echo "[INFO] Fixing udev rule (using SYSTEMD_USER_WANTS instead of SYSTEMD_WANTS)..."
sudo tee /etc/udev/rules.d/99-asus-profile-toast.rules >/dev/null <<EOF
KERNEL=="platform-profile-*", SUBSYSTEM=="platform-profile", ACTION=="change", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}="asus-profile-notify@$REAL_USER.service"
EOF

echo "[INFO] Reloading udev and enabling user service..."
sudo udevadm control --reload-rules
sudo -u "$REAL_USER" systemctl --user daemon-reload 2>/dev/null || true
sudo -u "$REAL_USER" systemctl --user enable asus-profile-notify@.service 2>/dev/null || true

echo "[INFO] Verifying service..."
if sudo -u "$REAL_USER" systemctl --user is-enabled asus-profile-notify@.service 2>/dev/null; then
    echo "[SUCCESS] User service is now enabled"
else
    echo "[WARNING] Service may not be enabled, but file is in place"
fi

echo ""
echo "[SUCCESS] Migration complete!"
echo "Press Fn+F5 to test the toast notification."