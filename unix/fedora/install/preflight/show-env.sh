#!/bin/bash
# Show installation environment variables

log_info "Installation Environment:"

env | grep -E "^(RIG_GIT_NAME|RIG_GIT_EMAIL|RIG_NEXTDNS_ID|RIG_SECUREBOOT|RIG_REPO|RIG_REF|RIG_PATH|RIG_INSTALL|RIG_CONFIG|USER|HOME)=" | sort | while IFS= read -r var; do
  log_info "  $var"
done
