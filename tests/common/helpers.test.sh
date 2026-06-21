section "Common helpers load"
setup_rig_env "fedora"
source "$RIG_REPO/unix/common/helpers/logging.sh"
source "$RIG_REPO/unix/common/helpers/common.sh"
source "$RIG_REPO/unix/common/helpers/platform.sh"

assert_success "log_info is defined" type log_info
assert_success "log_success is defined" type log_success
assert_success "log_warning is defined" type log_warning
assert_success "log_error is defined" type log_error
assert_success "run_logged is defined" type run_logged
assert_success "confirm is defined" type confirm
assert_success "cmd_exists is defined" type cmd_exists
assert_success "get_config is defined" type get_config
assert_success "detect_platform is defined" type detect_platform

section "Common dotfiles load"
source "$RIG_REPO/unix/common/dotfiles/stow.sh"
assert_success "stow_dotfiles is defined" type stow_dotfiles

section "Non-interactive mode"
setup_rig_env "fedora"
source "$RIG_REPO/unix/common/helpers/logging.sh"
source "$RIG_REPO/unix/common/helpers/common.sh"

assert_success "confirm auto-yes in NON_INTERACTIVE" bash -c "
  source '$RIG_REPO/unix/common/helpers/logging.sh'
  source '$RIG_REPO/unix/common/helpers/common.sh'
  export NON_INTERACTIVE=true
  confirm 'Test prompt' 'Y'
"

assert_success "confirm auto-no in NON_INTERACTIVE" bash -c "
  source '$RIG_REPO/unix/common/helpers/logging.sh'
  source '$RIG_REPO/unix/common/helpers/common.sh'
  export NON_INTERACTIVE=true
  ! confirm 'Test prompt' 'N'
"
