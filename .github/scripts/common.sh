#!/bin/bash

VALID_FPGA_FAMILIES=("xc7" "eos-s3")
VALID_EXAMPLES=("counter" "picosoc" "linux_litex")
VALID_OSES=("ubuntu" "centos")

function tuttest_exec() {
cat << EOF
  echo ""
  echo "==================================================================== "
  echo "CMD : tuttest $@                                                     "
  echo "OUTPUT:                                                              "
  echo ""
  echo '$(tuttest $@)'
  echo "-------------------------------------------------------------------- "
  echo ""
EOF
  tuttest "$@"
}

function assert_value_in_array() {
  tested_value=$1
  shift
  valid_array="$@"

  if [[ ! " ${valid_array[@]} "  =~ " $tested_value " ]]; then
     echo "assert: Unsupported value: \"${tested_value}\"" 1>&2
     echo "        Should be one of (${valid_array[@]})" 1>&2
     exit 1
  fi
}
