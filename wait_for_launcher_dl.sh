#!/bin/bash

# Check if contains command line arg
if [ -z "$1" ]; then
    echo "Missing command-line argument."
    exit 1
fi

url="https://github.com/R2Northstar/NorthstarLauncher/releases/tag/$1"
wait_time_seconds=60

# Loop until the response code changes
while true; do
    response=$(curl --silent --output /dev/null --write-out "%{http_code}" $url)
    if [ $response -ne 200 ]; then
        echo "Response is not 200. Retrying in $wait_time_seconds seconds."
        sleep $wait_time_seconds
    else
        echo "Site is accessible with response code $response."
        break
    fi
done

# 10 second sleep just in case we hit some weird race condition
# where files are still being uploaded but release is done
sleep 10
