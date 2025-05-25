#!/bin/sh

set -e
cd $(dirname $0)

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

# Color Definitions (ANSI Escape Codes)
RED="\e[1;31m"          # Bold Red
GREEN="\e[1;32m"         # Bold Green
PURPLE="\e[1;35m"        # Bold Purple (originally was non-bold)
LIGHT_RED="\e[00;31m"
GRAY="\e[1;37m"          # Bold Gray (light white)
LIGHT_GRAY="\e[0;37m"          # Bold Gray (light white)
RESET="\e[0m"            # Reset all attributes

vlib work >/dev/null

function print() {
  echo -e "$@" "$RESET"
}

mkdir -p logs

print -n "${GRAY}[Compiling sources]"
srcs=$(./dep_tree.sh)
for src in $srcs; do
  if ! $(vcom -2008 -quiet $src 2>&1 >"logs/compile.log"); then
    print "${RED}ERROR" >&2
    print "${LIGHT_RED}$(cat logs/compile.log)" >&2
    print "${GRAY} You can find the error in ${PURPLE}logs/compile.log"
    exit 1
  fi
done
print " ${GREEN}DONE"
