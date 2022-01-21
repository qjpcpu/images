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

PASSWORD=pwd
DIR=forks/$PORT
mkdir -p $DIR

(cat<<EOF
version: '2'

services:
  mongodb-sharded-$PORT:
    image: docker.io/bitnami/mongodb-sharded:$VERSION
    environment:
      - MONGODB_ADVERTISED_HOSTNAME=mongodb-sharded-$PORT
      - MONGODB_SHARDING_MODE=mongos
      - MONGODB_CFG_PRIMARY_HOST=mongodb-cfg-$PORT
      - MONGODB_CFG_REPLICA_SET_NAME=cfgreplicaset
      - MONGODB_REPLICA_SET_KEY=replicasetkey123
      - MONGODB_ROOT_PASSWORD=$PASSWORD
    ports:
      - "$PORT:27017"

  mongodb-shard-$PORT-0:
    image: docker.io/bitnami/mongodb-sharded:$VERSION
    environment:
      - MONGODB_ADVERTISED_HOSTNAME=mongodb-shard-$PORT-0
      - MONGODB_SHARDING_MODE=shardsvr
      - MONGODB_MONGOS_HOST=mongodb-sharded-$PORT
      - MONGODB_ROOT_PASSWORD=$PASSWORD
      - MONGODB_REPLICA_SET_MODE=primary
      - MONGODB_REPLICA_SET_KEY=replicasetkey123
      - MONGODB_REPLICA_SET_NAME=shard0
    volumes:
      - 'shard0_data-$PORT:/bitnami'

  mongodb-shard-$PORT-1:
    image: docker.io/bitnami/mongodb-sharded:$VERSION
    environment:
      - MONGODB_ADVERTISED_HOSTNAME=mongodb-shard-$PORT-1
      - MONGODB_SHARDING_MODE=shardsvr
      - MONGODB_MONGOS_HOST=mongodb-sharded-$PORT
      - MONGODB_ROOT_PASSWORD=$PASSWORD
      - MONGODB_REPLICA_SET_MODE=primary
      - MONGODB_REPLICA_SET_KEY=replicasetkey123
      - MONGODB_REPLICA_SET_NAME=shard1
    volumes:
      - 'shard1_data-$PORT:/bitnami'

  mongodb-cfg-$PORT:
    image: docker.io/bitnami/mongodb-sharded:$VERSION
    environment:
      - MONGODB_ADVERTISED_HOSTNAME=mongodb-cfg-$PORT
      - MONGODB_SHARDING_MODE=configsvr
      - MONGODB_ROOT_PASSWORD=$PASSWORD
      - MONGODB_REPLICA_SET_MODE=primary
      - MONGODB_REPLICA_SET_KEY=replicasetkey123
      - MONGODB_REPLICA_SET_NAME=cfgreplicaset
    volumes:
      - 'cfg_data-$PORT:/bitnami'

volumes:
  shard0_data-$PORT:
    driver: local
  shard1_data-$PORT:
    driver: local
  shard2_data-$PORT:
    driver: local
  cfg_data-$PORT:
    driver: local
EOF
) > $DIR/docker-compose.yml

(cd $DIR && docker-compose up -d)

STOPFILE=stop-$PORT.sh
(cat<<EOF
#!/bin/bash
(cd $DIR && docker-compose down -v)
rm -fr $DIR
EOF
) > $STOPFILE
chmod +x $STOPFILE

