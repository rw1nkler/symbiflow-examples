#!/bin/bash

set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${CURRENT_DIR}/common.sh

# -- validate input -----------------------------------------------------------

if [[ ! $# -eq 2 ]]; then
  echo "Invalid number of arguments"
  exit 1
fi

fpga_family=$1
os=$2

assert_value_in_array "${fpga_family}" "${VALID_FPGA_FAMILIES[@]}"
assert_value_in_array ${os} "${VALID_OSES[@]}"

# -- tuttest ------------------------------------------------------------------

tuttest_exec docs/getting-symbiflow.rst install-reqs-$os
tuttest_exec docs/getting-symbiflow.rst wget-conda
tuttest_exec docs/getting-symbiflow.rst conda-install-dir
tuttest_exec docs/getting-symbiflow.rst fpga-fam-$fpga_family
tuttest_exec docs/getting-symbiflow.rst conda-setup
tuttest_exec docs/getting-symbiflow.rst download-arch-def-$fpga_family
