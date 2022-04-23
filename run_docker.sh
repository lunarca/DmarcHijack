#!/bin/bash

# Stolen from https://github.com/BishopFox/GitGot/blob/master/gitgot-docker.sh
# Thanks Jake

if [[ -f "Dockerfile" ]]; then
    if [ -z $(docker images -q dmarc_hijack) ]; then
        # Display output on fresh container build
        docker build -t dmarc_hijack .
    else
        # Silent rebuild if in project directory
        docker build -t dmarc_hijack . 2>&1 > /dev/null
    fi
else
    echo "Not in project directory. Skipping container update/rebuild..."
fi

if [[ ! -d "results" ]]; then
    mkdir results
fi

docker run --rm -it \
    -v $PWD/results:/dmarc_hijack/results \
    dmarc_hijack mix "$@"