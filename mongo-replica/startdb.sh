#!/bin/bash

chmod 600 keyfile
docker-compose up -d

sleep 5

docker exec mongo1 /scripts/rs-init.sh
