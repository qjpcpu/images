#!/bin/bash
docker run --rm -p 27037:27017 -e MONGO_INITDB_ROOT_USERNAME=root -e MONGO_INITDB_ROOT_PASSWORD=pwd  --name mongo-single-27037  -d mongo:3.6 --master --bind_ip 0.0.0.0
