#!/bin/bash
# Hibernation + suspend-then-hibernate setup
# Requires Secure Boot DISABLED in BIOS/UEFI (kernel lockdown blocks hibernation)

echo "Configuring hibernation"

enable_hibernation=$(get_config '.performance.enable_hibernation')
swap_size_mb=$(get_config '.performance.hibernation_swap_size_mb')
hibernate_delay=$(get_config '.performance.hibernation_delay')

if [[ "$enable_hibernation" != "true" ]]; then
    log_info "Hibernation disabled in config"
    return 0
fi

log_warning "Hibernation requires Secure Boot DISABLED in BIOS/UEFI"
log_warning "Kernel lockdown (active with Secure Boot) blocks hibernation:"
log_warning "  'Lockdown: hibernation is restricted; see man kernel_lockdown.7'"

if ! confirm "Proceed with hibernation setup (Secure Boot must be off)?"; then
    log_info "Skipped hibernation setup"
    return 0
fi

# 1. Real disk swapfile on the encrypted root (zram cannot hibernate)
# Non-btrfs root: skip hibernation only. Returning 1 would abort the whole
# config phase because all.sh runs under `set -e`.
root_fs=$(findmnt -no FSTYPE /)
if [[ "$root_fs" != "btrfs" ]]; then
    log_warning "Root filesystem is ${root_fs}, not btrfs: swapfile setup requires btrfs"
    log_warning "Create a swap partition >= RAM and configure resume manually"
    return 0
fi

swapfile=/var/swap/swapfile
swap_size_mb=${swap_size_mb:-16384}

if ! [[ -f "$swapfile" ]]; then
    log_info "Creating swapfile (${swap_size_mb}MB) on encrypted root"
    # /var/swap must be a btrfs subvolume. mkdir -p would create a plain dir,
    # making `btrfs subvolume create` fail with "File exists".
    if ! btrfs subvolume show /var/swap &>/dev/null; then
        [[ -d /var/swap ]] && sudo rmdir /var/swap
        sudo btrfs subvolume create /var/swap
    fi
    sudo chattr +C /var/swap 2>/dev/null || true
    sudo btrfs filesystem mkswapfile --size "${swap_size_mb}M" "$swapfile"
else
    log_info "Swapfile already exists at $swapfile"
fi

if ! grep -qF "$swapfile" /etc/fstab; then
    log_info "Adding swapfile to /etc/fstab"
    sudo tee -a /etc/fstab > /dev/null <<EOF
$swapfile none swap defaults 0 0
EOF
fi

sudo swapon -av

# 2. Resume plumbing (resume=UUID + resume_offset for a btrfs swapfile)
resume_uuid=$(findmnt -no UUID -T "$swapfile")
resume_offset=$(sudo btrfs inspect-internal map-swapfile -r "$swapfile")

log_info "resume=UUID=${resume_uuid} resume_offset=${resume_offset}"

if ! grep -q "resume=" /proc/cmdline 2>/dev/null; then
    if cmd_exists grubby; then
        sudo grubby --update-kernel=ALL --args="resume=UUID=${resume_uuid} resume_offset=${resume_offset}"
        log_success "Kernel cmdline updated"
    else
        log_warning "grubby not available; add resume=UUID=${resume_uuid} resume_offset=${resume_offset} manually"
    fi
else
    log_info "resume= already present on kernel cmdline"
fi

# RTC alarm wakes s2idle systems so suspend-then-hibernate can fire on schedule
if grep -q "s2idle" /sys/power/mem_sleep 2>/dev/null; then
    if ! grep -q "rtc_cmos.use_acpi_alarm=1" /proc/cmdline 2>/dev/null; then
        if cmd_exists grubby; then
            sudo grubby --update-kernel=ALL --args="rtc_cmos.use_acpi_alarm=1"
            log_success "RTC alarm enabled for s2idle suspend-then-hibernate"
        else
            log_warning "grubby not available; add rtc_cmos.use_acpi_alarm=1 manually"
        fi
    else
        log_info "rtc_cmos.use_acpi_alarm=1 already present on kernel cmdline"
    fi
fi

echo 'add_dracutmodules+=" resume "' | sudo tee /etc/dracut.conf.d/resume.conf > /dev/null
sudo dracut -f --regenerate-all

if cmd_exists semanage; then
    sudo semanage fcontext --add --type swapfile_t "$swapfile" 2>/dev/null || true
    sudo restorecon -RF /var/swap
else
    log_warning "semanage not available; SELinux swapfile label not set"
    log_warning "If SELinux is enforcing, run: sudo semanage fcontext -a -t swapfile_t $swapfile && sudo restorecon -RF /var/swap"
fi

sudo systemctl daemon-reload
sudo mkdir -p /etc/systemd/sleep.conf.d
sudo tee /etc/systemd/sleep.conf.d/10-hibernate.conf > /dev/null <<EOF
[Sleep]
AllowSuspendThenHibernate=yes
HibernateDelaySec=${hibernate_delay:-30min}
EOF

sudo mkdir -p /etc/systemd/logind.conf.d
sudo tee /etc/systemd/logind.conf.d/10-suspend-then-hibernate.conf > /dev/null <<EOF
[Login]
HandleLidSwitch=suspend-then-hibernate
HandleLidSwitchExternalPower=suspend-then-hibernate
HandleLidSwitchDocked=suspend
EOF

sudo systemctl daemon-reload

lockdown=$(cat /sys/kernel/security/lockdown 2>/dev/null || echo "unknown")
if [[ "$lockdown" == *"["* ]]; then
    log_warning "Kernel lockdown is ACTIVE (${lockdown}): hibernation will fail until Secure Boot is disabled"
else
    log_success "No kernel lockdown detected: hibernation should work"
fi

log_warning "NEXT STEPS (manual):"
log_warning "  1. Disable Secure Boot in BIOS (Security -> Secure Boot -> OS Type = Other OS)"
log_warning "  2. Re-enroll TPM2 for LUKS (PCR 7 includes Secure Boot state):"
log_warning "     sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p3"
log_warning "  3. Verify: cat /sys/power/disk (must NOT show [disabled])"
log_warning "  4. Test: sudo systemctl suspend-then-hibernate"

log_success "Hibernation configured"
