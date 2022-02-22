VERSION=$1
PORT=$2
USER=root
PWD=pwd
if [ -z "$VERSION" ];then
        echo "need version"
        exit 1
fi
if [ -z "$PORT" ];then
        echo "need port"
        exit 1
fi

DIR=forks/$PORT
mkdir -p $DIR

(cat<<EOF
version: '2'

services:
  postgresql-master:
    image: docker.io/bitnami/postgresql:$VERSION
    ports:
      - $PORT:5432
    volumes:
      - 'postgresql_master_data:/bitnami/postgresql'
      - ./conf.d:/bitnami/postgresql/conf/conf.d
    environment:
      - POSTGRESQL_REPLICATION_MODE=master
      - POSTGRESQL_REPLICATION_USER=repl_user
      - POSTGRESQL_REPLICATION_PASSWORD=repl_password
      - POSTGRESQL_USERNAME=$USER
      - POSTGRESQL_PASSWORD=$PWD
      - POSTGRESQL_DATABASE=my_database
      - ALLOW_EMPTY_PASSWORD=yes
  postgresql-slave:
    image: docker.io/bitnami/postgresql:$VERSION
    ports:
      - '5432'
    depends_on:
      - postgresql-master
    environment:
      - POSTGRESQL_REPLICATION_MODE=slave
      - POSTGRESQL_REPLICATION_USER=repl_user
      - POSTGRESQL_REPLICATION_PASSWORD=repl_password
      - POSTGRESQL_MASTER_HOST=postgresql-master
      - POSTGRESQL_USERNAME=$USER
      - POSTGRESQL_PASSWORD=$PWD
      - POSTGRESQL_MASTER_PORT_NUMBER=5432
      - ALLOW_EMPTY_PASSWORD=yes

volumes:
  postgresql_master_data:
    driver: local
EOF
) > $DIR/docker-compose.yml

# create stop.sh
STOPFILE=stop-$PORT.sh
(cat<<EOF
#!/bin/bash
(cd $DIR && docker-compose down -v)
rm -f \$0 && rm -fr $DIR
EOF
) > $STOPFILE
chmod +x $STOPFILE

# start
(cp -a conf.d $DIR && cd $DIR && docker-compose up -d)
