#!/bin/sh

cd $(dirname $0)
set -e
vhdeps dump -i work:../src -i work:./tbs | awk '{print $4}' 
