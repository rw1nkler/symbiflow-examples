#!/bin/bash

set -e

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source ${CURRENT_DIR}/common.sh

# -- validate input ----------------------------------------------------------

if [[ ! $# -ge 2 ]]; then
  echo "Invalid number of arguments!"
  exit 1
fi

fpga_family=$1
shift
examples="$@"

assert_value_in_array ${fpga_family} "${VALID_FPGA_FAMILIES[@]}"
for example in $examples; do
  echo "example: ${example}"
  echo "valid_examples: ${VALID_EXAMPLES[@]}"
  assert_value_in_array ${example} "${VALID_EXAMPLES[@]}"
done

# -- tuttest -----------------------------------------------------------------

# activate conda and enter example dir
tuttest docs/building-examples.rst export-install-dir
tuttest docs/building-examples.rst fpga-fam-$fpga_family
tuttest docs/building-examples.rst conda-prep-env
tuttest docs/building-examples.rst conda-act-env
tuttest docs/building-examples.rst enter-dir-$fpga_family

if [ "$fpga_family" = "xc7" ]; then
    # Xilinx 7-Series examples
    for example in $examples; do
        case $example in
            "counter")
                tuttest xc7/counter_test/README.rst example-counter-a35t-group
                tuttest xc7/counter_test/README.rst example-counter-a100t-group
                tuttest xc7/counter_test/README.rst example-counter-basys3-group
                ;;
            "picosoc")
                tuttest xc7/picosoc_demo/README.rst example-picosoc-basys3-group
                ;;
            "linux_litex")
                tuttest xc7/linux_litex_demo/README.rst example-litex-deps
                tuttest xc7/linux_litex_demo/README.rst example-litex-a35t-group
                tuttest xc7/linux_litex_demo/README.rst example-litex-a100t-group
                ;;
        esac
    done
else
    # QuickLogic EOS-S3 examples
    tuttest eos-s3/btn_counter/README.rst eos-s3-counter
fi;
