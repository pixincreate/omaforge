section "Fedora helpers load"
setup_rig_env "fedora"
source "$RIG_REPO/unix/fedora/install/helpers/all.sh"

assert_success "log_info is defined" type log_info
assert_success "log_success is defined" type log_success
assert_success "run_logged is defined" type run_logged
assert_success "confirm is defined" type confirm
assert_success "cmd_exists is defined" type cmd_exists
assert_success "get_config is defined" type get_config
assert_success "pkg_installed is defined" type pkg_installed

section "Fedora run_logged basic execution"
setup_rig_env "fedora"
source "$RIG_REPO/unix/fedora/install/helpers/all.sh"

cat > /tmp/rig-test-script-$$.sh << 'EOF'
#!/bin/bash
echo "hello from test"
exit 0
EOF
chmod +x /tmp/rig-test-script-$$.sh
assert_success "run_logged succeeds" bash -c "
  source '$RIG_REPO/unix/fedora/install/helpers/all.sh'
  export RIG_PATH='$RIG_REPO/unix/fedora'
  export RIG_INSTALL='$RIG_REPO/unix/fedora/install'
  export RIG_CONFIG='$RIG_REPO/unix/fedora/config.json'
  export NON_INTERACTIVE=true
  export RIG_INSTALL_LOG_FILE='/tmp/rig-test-$$.log'
  run_logged '/tmp/rig-test-script-$$.sh'
"
rm -f /tmp/rig-test-script-$$.sh

section "Fedora dotfiles scripts syntax"
setup_rig_env "fedora"
for f in "$RIG_INSTALL/dotfiles/"*.sh; do
    [[ -f "$f" ]] && assert_bash_syntax "$(basename "$f")" "$f"
done

section "Fedora config scripts syntax"
setup_rig_env "fedora"
for f in "$RIG_INSTALL/config/"*.sh; do
    [[ -f "$f" ]] && assert_bash_syntax "$(basename "$f")" "$f"
done
for d in "$RIG_INSTALL/config/"*/; do
    [[ -d "$d" ]] || continue
    for f in "$d"*.sh; do
        [[ -f "$f" ]] && assert_bash_syntax "config/$(basename "$d")/$(basename "$f")" "$f"
    done
done

section "Fedora non-interactive mode"
setup_rig_env "fedora"
source "$RIG_REPO/unix/fedora/install/helpers/all.sh"

assert_success "confirm auto-yes in NON_INTERACTIVE" bash -c "
  export NON_INTERACTIVE=true
  source '$RIG_REPO/unix/fedora/install/helpers/all.sh'
  confirm 'Test prompt' 'Y'
"

assert_success "confirm auto-no in NON_INTERACTIVE" bash -c "
  export NON_INTERACTIVE=true
  source '$RIG_REPO/unix/fedora/install/helpers/all.sh'
  ! confirm 'Test prompt' 'N'
"
