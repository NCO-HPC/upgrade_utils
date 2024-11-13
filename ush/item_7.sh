#! /usr/bin/env bash
######
# Puprpose:
#checks for  J-job scripts cd to the jobs working directory ($DATA) 
#before running any commands that generate output files (eg, setpdy.sh)
#
#####
# Usage 
# $ this_code path/to/para/package

if [ "$#" -eq 0 ]; then
    echo "This script checks that J-Job cds to DATA"
    echo "Usage : $0 /path/to/package:"
    exit 1
fi

target_add=$1

check_cd_to_data() {
    local script_file="$1"
    found_cd_data=0
    found_output_command=0

    while IFS= read -r line; do
        # Skip empty lines or comments
        line=$(echo "$line" | sed 's/#.*//')
        [[ -z "$line" ]] && continue
        if echo "$line" | grep -qE 'cd[[:space:]]+(\$DATA|\$\{DATA\}|DATA)'; then
#            echo found_data in $line
            found_cd_data=1
        fi

        # Look for output-generating commands like setpdy.sh
        if echo "$line"  | grep -qE '(^[[:space:]]*\.(\/|[[:space:]]+)[^[:space:]]+)|(^[[:space:]]*setpdy\.sh)';then
            found_output_command=1
#            echo found_command in : $line
            if [ "$found_cd_data" -eq 0 ]; then
                echo "Error: 'cd DATA' not found before 'setpdy.sh' or output making command in $script_file"
                return 1
            fi
        fi
    done < "$script_file"

    # Final check
    if [ "$found_output_command" -eq 1 ] && [ "$found_cd_data" -eq 1 ]; then
        echo "Check passed: 'cd DATA' is correctly placed before output commands in $script_file"
    elif [ "$found_output_command" -eq 0 ]; then
        echo "No output-generating command found in $script_file"
    fi
}


pushd $target_add > /dev/null
for jfile in $(find ./jobs/* -type f); do
    check_cd_to_data $jfile
done
