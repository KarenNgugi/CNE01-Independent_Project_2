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

# check if Docker is installed, exit if it's not
if command -v docker &> /dev/null; then
	DOCKER_VERSION=$(docker --version | awk '{print $3}')
	printf "\U0001F40B Docker version $DOCKER_VERSION detected! \U0002705\n"
else
	printf "\U0001F40B Docker is not installed! \U000274C\n"
	printf "Please install Docker at https://www.docker.com/get-started/ then try again.\n"
	echo "Exiting with code 1."
	exit 1
fi
