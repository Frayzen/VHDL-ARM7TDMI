#!/bin/sh

. ./compile.sh

which fzf >/dev/null
if [ $? -ne 0 ]; then
  echo "Please install gum first";
fi

select=$(find tbs -name "*.vhd" -exec basename {} .vhd \; | fzf)
if [ -z $select ]; then
  exit 0;
fi

vsim -do "\
vlib work;\
vsim $select;\
add wave -recursive $select/*;\
run -all;\
config wave -signalnamewidth 1
wave zoom full;
"
