#!/bin/bash
# usage: stop.sh port
PORT=$1
if [ -z "$PORT" ];then
        echo "need port"
        exit 1
fi
docker stop mysql-$PORT
