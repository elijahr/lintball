#!/usr/bin/env bash

set -ueo pipefail

if [ -n "${CI:-}" ]; then
  # on CI systems show debug output
  set -x
fi

LB_DIR="${1:-"${HOME}/.lintball"}"
# shellcheck source=SCRIPTDIR/lib/install.bash
source "${LB_DIR}/lib/install.bash"

update_lintball

# After update, re-source lib/install.bash for new functions
# shellcheck source=SCRIPTDIR/lib/install.bash
source "${LB_DIR}/lib/install.bash"

update_deps
add_inits
