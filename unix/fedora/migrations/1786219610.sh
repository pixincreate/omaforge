#!/bin/bash
set -eEuo pipefail

echo "Running migration: Zram sysctl tuning, hibernation swapfile + resume, secure boot prep"

echo ""
echo "[1/4] Applying sysctl tuning..."

mem_total_kb=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
ram_mb=$(( mem_total_kb / 1024 ))

zram_mb=0
if [[ -f /sys/block/zram0/disksize ]]; then
  zram_mb=$(( $(cat /sys/block/zram0/disksize) / 1024 / 1024 ))
fi

if (( zram_mb > 0 )); then
  if (( zram_mb >= ram_mb )); then
    swap_swappiness=150
    echo "[INFO] zram (${zram_mb}MB) >= RAM (${ram_mb}MB): swappiness=150 (zram swap is faster than page re-read)"
  else
    swap_swappiness=100
    echo "[WARNING] zram (${zram_mb}MB) < RAM (${ram_mb}MB): capping swappiness at 100 to avoid swap thrash"
  fi

  sudo tee /etc/sysctl.d/99-performance.conf >/dev/null <<EOF
net.ipv4.tcp_mtu_probing=1
vm.swappiness=${swap_swappiness}
vm.vfs_cache_pressure=50
vm.page-cluster=0
vm.watermark_boost_factor=0
vm.watermark_scale_factor=125
vm.dirty_background_bytes=67108864
vm.dirty_bytes=268435456
vm.dirty_writeback_centisecs=1500
EOF
else
  echo "[INFO] No zram device found, skipping zram tuning"
fi

sudo tee /etc/sysctl.d/99-inotify.conf >/dev/null <<EOF
fs.inotify.max_user_watches=524288
EOF

sudo sysctl --system >/dev/null
echo "[SUCCESS] Sysctl tuning applied"

echo ""
echo "[2/4] Setting up hibernation swapfile..."

root_fs=$(findmnt -no FSTYPE /)
if [[ "$root_fs" != "btrfs" ]]; then
  echo "[WARNING] Root is ${root_fs}, not btrfs: swapfile setup requires btrfs"
  echo "[WARNING] Create a swap partition >= RAM manually"
else
  swapfile=/var/swap/swapfile
  if ! [[ -f "$swapfile" ]]; then
    echo "[INFO] Creating 16G swapfile (matches RAM size)"
    # /var/swap must be a btrfs subvolume. mkdir -p would create a plain dir,
    # making `btrfs subvolume create` fail with "File exists".
    if ! btrfs subvolume show /var/swap &>/dev/null; then
      [[ -d /var/swap ]] && sudo rmdir /var/swap
      sudo btrfs subvolume create /var/swap
    fi
    sudo chattr +C /var/swap 2>/dev/null || true
    sudo btrfs filesystem mkswapfile --size 16384M "$swapfile"
  else
    echo "[INFO] Swapfile already exists"
  fi

  if ! grep -qF "$swapfile" /etc/fstab; then
    echo "[INFO] Adding swapfile to /etc/fstab"
    sudo tee -a /etc/fstab >/dev/null <<EOF
$swapfile none swap defaults 0 0
EOF
  fi
  sudo swapon -av

  if ! grep -q "resume=" /proc/cmdline 2>/dev/null; then
    resume_uuid=$(findmnt -no UUID -T "$swapfile")
    resume_offset=$(sudo btrfs inspect-internal map-swapfile -r "$swapfile")
    echo "[INFO] resume=UUID=${resume_uuid} resume_offset=${resume_offset}"
    if command -v grubby &>/dev/null; then
      sudo grubby --update-kernel=ALL --args="resume=UUID=${resume_uuid} resume_offset=${resume_offset}"
      echo "[SUCCESS] Kernel cmdline updated with resume args"
    else
      echo "[WARNING] grubby not available; add resume=UUID=${resume_uuid} resume_offset=${resume_offset} manually"
    fi
  else
    echo "[INFO] resume= already present on kernel cmdline"
  fi

  # RTC alarm wakes s2idle systems so suspend-then-hibernate can fire on schedule
  if grep -q "s2idle" /sys/power/mem_sleep 2>/dev/null; then
    if ! grep -q "rtc_cmos.use_acpi_alarm=1" /proc/cmdline 2>/dev/null; then
      echo "[INFO] s2idle detected: enabling RTC alarm for scheduled hibernation"
      if command -v grubby &>/dev/null; then
        sudo grubby --update-kernel=ALL --args="rtc_cmos.use_acpi_alarm=1"
        echo "[SUCCESS] RTC alarm enabled"
      else
        echo "[WARNING] grubby not available; add rtc_cmos.use_acpi_alarm=1 manually"
      fi
    else
      echo "[INFO] rtc_cmos.use_acpi_alarm=1 already present on kernel cmdline"
    fi
  fi

  echo 'add_dracutmodules+=" resume "' | sudo tee /etc/dracut.conf.d/resume.conf >/dev/null
  sudo dracut -f --regenerate-all

  if command -v semanage &>/dev/null; then
    sudo semanage fcontext --add --type swapfile_t "$swapfile" 2>/dev/null || true
    sudo restorecon -RF /var/swap
  else
    echo "[WARNING] semanage not available; SELinux swapfile label not set"
  fi
fi

echo ""
echo "[3/4] Configuring suspend-then-hibernate..."

sudo mkdir -p /etc/systemd/sleep.conf.d
sudo tee /etc/systemd/sleep.conf.d/10-hibernate.conf >/dev/null <<EOF
[Sleep]
AllowSuspendThenHibernate=yes
HibernateDelaySec=30min
EOF

sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/10-suspend-then-hibernate.conf >/dev/null <<EOF
[Login]
HandleLidSwitch=suspend-then-hibernate
HandleLidSwitchExternalPower=suspend-then-hibernate
HandleLidSwitchDocked=suspend
EOF

sudo systemctl daemon-reload
echo "[SUCCESS] Suspend-then-hibernate configured"

echo ""
echo "[4/4] Checking Secure Boot status..."

lockdown=$(cat /sys/kernel/security/lockdown 2>/dev/null || echo "unknown")
if [[ "$lockdown" == *"["* ]]; then
  echo ""
  echo "[WARNING] Kernel lockdown is ACTIVE (${lockdown})"
  echo "[WARNING] Hibernation will FAIL until Secure Boot is disabled"
  echo ""
  echo "Next steps (manual):"
  echo "  1. Reboot into BIOS: Security -> Secure Boot -> OS Type = Other OS (or Disabled)"
  echo "  2. Reboot normally"
  echo "  3. Re-enroll TPM2 (PCR 7 includes Secure Boot state):"
  echo "     sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+1+7 /dev/nvme0n1p3"
  echo "  4. Verify: cat /sys/power/disk  (must NOT show [disabled])"
  echo "  5. Test: sudo systemctl suspend-then-hibernate"
else
  echo "[SUCCESS] No kernel lockdown detected: hibernation should work"
fi

echo ""
echo "[SUCCESS] Migration complete!"
