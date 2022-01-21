#!/bin/bash
VERSION=$1
PORT=$2
if [ -z "$VERSION" ];then
        echo    "need version"
        exit 1
fi

if [ -z "$PORT" ];then
        echo "need port"
        exit 1
fi
docker run -d --name postgresAduit-$VERSION-$PORT --rm -p $PORT:5432 -e POSTGRESQL_USERNAME=root -e POSTGRESQL_PASSWORD=pwd -e POSTGRESQL_DATABASE=mydb  -e POSTGRESQL_PGAUDIT_LOG=all -e POSTGRESQL_WAL_LEVEL=logical bitnami/postgresql:$VERSION

STOPFILE=stop-$VERSION-$PORT.sh
(cat<<EOF
#!/bin/bash
docker stop postgresAduit-$VERSION-$PORT
rm -f \$0
EOF
)>$STOPFILE
chmod +x $STOPFILE
