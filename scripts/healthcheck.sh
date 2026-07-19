# use this instead of hardcoding /bin/bash
#!/usr/bin/env bash

# make pipeline exit on failure
set -euo pipefail

# obtaining backend & frontend container names
BACKEND_CONTAINER="tracker-backend"
FRONTEND_CONTAINER="tracker-frontend"

# check if backend container exists
if ! docker inspect -f json $BACKEND_CONTAINER > /dev/null 2>&1; then
	echo "Container '$BACKEND_CONTAINER' not found! Exiting with code 1."
	printf "Backend healthcheck status: FAIL \U000274C\n"
	exit 1
  
else
	echo "Container '$BACKEND_CONTAINER' found!"
  
	# check backend container state
	if [ "$(docker inspect -f '{{ .State.Status }}' $BACKEND_CONTAINER)" = "exited" ]; then
		echo "Container '$BACKEND_CONTAINER' is stopped! Please start it up and try again. Exiting with code 1."
		printf "Backend healthcheck status: FAIL \U000274C\n"
		exit 1
    
	elif [ "$(docker inspect -f '{{ .State.Status }}' $BACKEND_CONTAINER)" = "running" ]; then
		echo "Container '$BACKEND_CONTAINER' is running!"
    
		# check if it has "Health" attribute
		if [ "$(docker inspect -f '{{ .State.Health }}' $BACKEND_CONTAINER)" = "<nil>" ]; then
			echo "Container '$BACKEND_CONTAINER' does not have HEALTHCHECK enabled. Exiting with code 1."
			printf "Backend healthcheck status: FAIL \U000274C\n"
			exit 1
      
		else 
			echo "Container '$BACKEND_CONTAINER' has HEALTHCHECK enabled."
      
			if [ "$(docker inspect -f '{{ .State.Health.Status }}' $BACKEND_CONTAINER)" = "healthy" ]; then
				echo "Container '$BACKEND_CONTAINER' is healthy!"
        
			elif [ "$(docker inspect -f '{{ .State.Health.Status }}' $BACKEND_CONTAINER)" = "unhealthy" ]; then
				printf "Container '$BACKEND_CONTAINER' is unhealthy!\nLast error log:\n"
				docker inspect tracker-backend | jq -r '.[-1].State.Health.Log | last | .Output'
				echo "Exiting with code 1."
				printf "Backend healthcheck status: FAIL \U000274C\n"
				exit 1
        
			elif [ "$(docker inspect -f '{{ .State.Health.Status }}' $BACKEND_CONTAINER)" = "starting" ]; then
				echo "Container '$BACKEND_CONTAINER' is starting. Try again in a bit."
				printf "Backend healthcheck status: FAIL \U000274C\n"
				exit 1
        
			else
				echo "Something went mysteriously wrong! Lo siento."
				printf "Backend healthcheck status: FAIL \U000274C\n"
				exit 1
        
			fi
		fi
	fi
fi

# pass backend healthcheck if all tests pass
printf "Backend healthcheck status: PASS \U0002705\n"
