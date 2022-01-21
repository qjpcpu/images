#!/bin/bash
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
docker run --rm -p $PORT:27017 -e MONGO_INITDB_ROOT_USERNAME=root -e MONGO_INITDB_ROOT_PASSWORD=pwd  --name mongo-standalone-$VERSION-$PORT  -d mongo:$VERSION --bind_ip 0.0.0.0


STOPFILE=stop-$VERSION-$PORT.sh
(cat<<EOF
#!/bin/bash
docker stop mongo-standalone-$VERSION-$PORT
rm -f \$0
EOF
) > $STOPFILE
chmod +x $STOPFILE
