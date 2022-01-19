#!/bin/bash
# usage: startdb.sh version port
VERSION=$1
PORT=$2
if [ -z "$VERSION" ];then
	echo "need version"
	exit 1
fi
if [ -z "$PORT" ];then
	echo "need port"
	exit 1
fi
docker run -it --rm --name mysql-$PORT -p $PORT:3306 -v $PWD/conf:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=pwd -d mysql:$VERSION --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
