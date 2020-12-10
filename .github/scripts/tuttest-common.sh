#!/bin/bash

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
