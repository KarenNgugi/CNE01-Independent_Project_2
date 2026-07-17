# use this instead of hardcoding /bin/bash
#!/usr/bin/env bash

# make pipeline exit on failure
set -euo pipefail

# no proceeding until exactly one argument is provided
while [ $# -ne 1 ]
do
	if [ $# -eq 0 ]; then
		IFS=' ' read -p "You need to provide a tag! " BUILD_TAG
		set -- $BUILD_TAG
	elif [ $# -gt 1 ]; then
		IFS=' ' read -p "Too many arguments provided!  " BUILD_TAG
		set -- $BUILD_TAG
	fi
done

BUILD_TAG=$1
echo "Setting tag: $BUILD_TAG"
