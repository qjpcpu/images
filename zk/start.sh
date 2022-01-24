#!/bin/bash
PORT=$1
if [ -z "$PORT" ];then
	echo "need port"
	exit 1
fi
docker run --name zookeeper-$PORT --rm -p $PORT:2181  -d zookeeper

STOPFILE=stop-$PORT.sh
(cat<<EOF
#!/bin/bash
docker stop zookeeper-$PORT
rm -f \$0
EOF
) > $STOPFILE
chmod +x $STOPFILE
