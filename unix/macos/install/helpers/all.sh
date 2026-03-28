#!/bin/bash
# Load all helper functions

OMAFORGE_COMMON_HELPERS="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../common/helpers" && pwd)"
OMAFORGE_COMMON_INSTALL="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../common/install" && pwd)"
export OMAFORGE_COMMON_HELPERS
export OMAFORGE_COMMON_INSTALL

source "$OMAFORGE_COMMON_HELPERS/logging.sh"
source "$OMAFORGE_COMMON_HELPERS/common.sh"
source "$OMAFORGE_INSTALL/helpers/logging.sh"
source "$OMAFORGE_INSTALL/helpers/common.sh"
