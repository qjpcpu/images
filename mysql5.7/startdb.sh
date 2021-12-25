#!/bin/bash
docker run -it --rm --name my-mysql_5.7 -p 13306:3306 -v $PWD/conf:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=pwd -d mysql:5.7 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
