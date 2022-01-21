#!/bin/bash
VERSION=$1
PORT=$2
if [ -z "$VERSION" ];then
	echo 	"need version"
	exit 1
fi

if [ -z "$PORT" ];then
	echo "need port"
	exit 1
fi
docker run --name postgres-$VERSION-$PORT --rm -p  $PORT:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=pwd -e POSTGRES_DB=mydb   -d postgres:$VERSION postgres -c wal_level=logical

#kdocker run --name postgres-$VERSION-$PORT --rm -p  $PORT:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=pwd -e POSTGRES_DB=mydb  -e PGDATA=/var/lib/postgresql/data/pgdata -v $PWD/data:/var/lib/postgresql/data -d postgres:11 postgres -c wal_level=logical
STOPFILE=stop-$VERSION-$PORT.sh
(cat<<EOF
#!/bin/bash
docker stop postgres-$VERSION-$PORT
rm -f \$0
EOF
)>$STOPFILE
chmod +x $STOPFILE
