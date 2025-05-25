#!/bin/sh

cd $(dirname $0)
. ./compile.sh

print "${GRAY}[Running tests]"

function run_test()
{
  # Extract test name without extension
  test_name=$(basename "$1" .vhd)
  
  # Run in batch mode (-c)
  set +e
  {
    timeout 2s vsim -c -do "\
    vsim ${test_name}; \
    run -all; \
    quit -f"
  } >"logs/${test_name}_sim.log" 2>&1
  code=$?
  set -e
  if [ $code -eq 124 ]; then
      echo -e "${RED}Test $test_name TIMED OUT${RESET}"
    elif [ "$(cat logs/${test_name}_sim.log | grep 'Errors: 0')" = "" ]; then
      echo -e "${RED}Test $test_name FAILED${RESET}"
  else
    echo -e "${GREEN}Test $test_name PASSED${RESET}"
  fi
}

for test in $(find tbs -name "*.vhd"); do
  run_test $test &
done

wait

  
print "${PURPLE}Log saved to logs"
