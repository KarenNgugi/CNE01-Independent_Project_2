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

# setting image names
BACKEND_NAME="backend-image"
FRONTEND_NAME="frontend-image"

# starting from scripts/ 
cd "$(dirname "$0")"

# moving to backend/ and initiating build process
cd "../backend"
printf "\nNow building the backend image with build tag $BUILD_TAG. Please wait...\U00023F3\n"
docker build -t "$BACKEND_NAME:$BUILD_TAG" .
if [ $? -eq 0 ]; then
	printf "Image $BACKEND_NAME:$BUILD_TAG successfully built! \U0001F973\n\n"
else
	printf "Something went wrong! Aborting with exit code 1! \U00026D4\n\n"
	exit 1
fi

# moving to frontend/ and initiating build process
cd "../frontend"
printf "\nNow building the frontend image with build tag $BUILD_TAG. Please wait...\U00023F3\n"
docker build -t "$FRONTEND_NAME:$BUILD_TAG" .
if [ $? -eq 0 ]; then
	printf "Image $FRONTEND_NAME:$BUILD_TAG successfully built! \U0001F973\n\n"
else
	printf "Something went wrong! Aborting with exit code 1! \U00026D4\n\n"
	exit 1
fi

