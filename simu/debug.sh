#!/bin/sh

RED="\e[1;31m"          # Bold Red
RESET="\e[0m"            # Reset all attributes
cd $(dirname $0)

if [ $# -eq 0 ]; then
  which fzf >/dev/null
  if [ $? -ne 0 ]; then
    echo -e "${RED}Please install fzf first. You can also execute this script with the test name in argument (without the .vhd extension)"; >&2
    echo -e "Here is the list of the possible tests:" >&2
    echo -e $(find tbs -name "*.vhd" -exec echo - \; -exec basename {} .vhd \;) >&2
    echo -e -n "$RESET"
    exit 1
  fi
  select=$(find tbs -name "*.vhd" -exec basename {} .vhd \;  | fzf)
else
  select=$1
  if [ ! -f "tbs/$select.vhd" ]; then 
    echo -e "${RED}Invalid test name" >&2
    echo -e -n "$RESET"
    exit 1
  fi
fi

if [ -z $select ]; then
  exit 0;
fi

cd -

. ./$(dirname $0)/compile.sh

vsim -do "\
vlib work;\
vsim $select;\
add wave *;\
run -all;\
config wave -signalnamewidth 1
wave zoom full;
"
