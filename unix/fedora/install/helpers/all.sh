#!/bin/bash
set -eEuo pipefail

RIG_COMMON_HELPERS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../common/helpers" && pwd)"
RIG_COMMON_INSTALL="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../common/install" && pwd)"
export RIG_COMMON_HELPERS
export RIG_COMMON_INSTALL

source "$RIG_COMMON_HELPERS/logging.sh"
source "$RIG_COMMON_HELPERS/common.sh"
source "$RIG_INSTALL/helpers/logging.sh"
source "$RIG_INSTALL/helpers/common.sh"
source "$RIG_INSTALL/helpers/presentation.sh"
