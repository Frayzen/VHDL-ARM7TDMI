#!/bin/sh

set -e
RED="\e[1;31m"          # Bold Red

# Dependency analyzer for VHDL files
# Outputs files in correct compilation order

# Configuration
SRC_DIR="../src"
TB_DIR="tbs/"

# Temporary files
DEPS_FILE=".vhdl_deps.tmp"
TEMP_GRAPH=".vhdl_graph.tmp"

# Clean up previous runs
rm -f $DEPS_FILE $TEMP_GRAPH 

# Find all VHDL files
find $SRC_DIR $TB_DIR -name "*.vhd" | while read file; do
    # Extract library/package dependencies
    deps=$(grep -E "library|use" "$file" | grep -oP '(?<=work\.)[a-zA-Z0-9_]+(?=\.|;)' | tr '\n' ' ')
    
    # Extract entity/package being defined
    entity=$(grep -E "entity [a-zA-Z0-9_]+|package [a-zA-Z0-9_]+" "$file" | head -1 | awk '{print $2}')
    
    if [ -n "$entity" ]; then
        echo "$entity $file $deps" >> $DEPS_FILE
    else
        echo "$RANDOM $file" >> $DEPS_FILE
    fi
done

# Generate dependency graph (simple topological sort)
declare -A visited
declare -a order

function visit {
    local node=$1
    local file=$2
    if [ "${visited[$node]}" == "temp" ]; then
        echo "Circular dependency detected involving $node"
        exit 1
    fi
    if [ -z "${visited[$node]}" ]; then
        visited[$node]="temp"
        # Get dependencies for this node
        deps=$(grep "^$node " $DEPS_FILE | cut -d' ' -f3-)
        for dep in $deps; do
            dep_file=$(grep "^$dep " $DEPS_FILE | awk '{print $2}')
            if [ -n "$dep_file" ]; then
                visit "$dep" "$dep_file"
            fi
        done
        visited[$node]="done"
        order+=("$file")
    fi
}

# Process all entities/packages
while read -r line; do
    entity=$(echo "$line" | awk '{print $1}')
    file=$(echo "$line" | awk '{print $2}')
    if [ -z "${visited[$entity]}" ]; then
        visit "$entity" "$file"
    fi
done < $DEPS_FILE

# Output compilation order
printf "%s\n" "${order[@]}"

# Clean up
rm -f $DEPS_FILE $TEMP_GRAPH
