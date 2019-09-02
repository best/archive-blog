#!/bin/bash

if [ -n "$1" ]; then
    docker version && docker ps -a
    docker network create web --subnet=172.19.0.0/16 --gateway=172.19.0.1
    docker stop blog && docker rm blog && docker rmi $1/blog
    docker run -d --name blog \
        --network web \
        --ip 172.19.0.2 \
        --restart always \
        $1/blog
    docker ps -a
else
    echo "parameter must be specified"
fi
