#!/bin/bash
docker run --name myzk --rm -p 12181:2181 --name myzk  -d zookeeper
