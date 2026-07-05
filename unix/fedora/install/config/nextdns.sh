#!/bin/bash

COMMON_SCRIPT="$RIG_PATH/../common/config/nextdns.sh"

if [[ ! -f "$COMMON_SCRIPT" ]]; then
    log_error "Common nextdns setup script not found: $COMMON_SCRIPT"
    return 1
fi

# Source the common script
# shellcheck source=../../../common/config/nextdns.sh
source "$COMMON_SCRIPT"

nextdns_id=$(get_config '.nextdns.config_id' 2>/dev/null || true)
device_name=$(get_config '.system.hostname' 2>/dev/null || true)

setup_nextdns "$nextdns_id" "$device_name"
