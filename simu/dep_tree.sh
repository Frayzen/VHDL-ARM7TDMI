#!/bin/sh

cd $(dirname $0)
set -e

includes=$(find ../src ./tbs -type d | sed 's/^/-i work:/' | tr '\n' ' ')

vhdeps dump $(echo $includes) | awk '{print $4}' 
