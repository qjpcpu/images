#!/bin/bash

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

PORT1=`expr $PORT + 1`
PORT2=`expr $PORT + 2`
DIR=forks/$PORT

mkdir -p $DIR

# create keyfile
openssl rand -base64 756 > $DIR/keyfile
chmod 400 $DIR/keyfile

# create docker-compose file
(cat<<EOF
version: '3.8'

services:
  replica-$VERSION-$PORT-1:
    container_name: replica-$VERSION-$PORT-1
    image: mongo:$VERSION
    volumes:
      - ./data/data1:/data/db
      - ./rs-init.sh:/scripts/rs-init.sh
      - ./keyfile:/scripts/keyfile
    networks:
      - mongors-network-$PORT
    ports:
      - $PORT:27017
    links:
      - replica-$VERSION-$PORT-2
      - replica-$VERSION-$PORT-3
    restart: always
    entrypoint: [ "/usr/bin/mongod", "--bind_ip_all", "--replSet", "rs0" ,"--keyFile","/scripts/keyfile"]
  replica-$VERSION-$PORT-2:
    container_name: replica-$VERSION-$PORT-2
    image: mongo:$VERSION
    volumes:
      - ./data/data2:/data/db
      - ./keyfile:/scripts/keyfile
    networks:
      - mongors-network-$PORT
    ports:
      - $PORT1:27017
    restart: always
    entrypoint: [ "/usr/bin/mongod", "--bind_ip_all", "--replSet", "rs0" ,"--keyFile","/scripts/keyfile"]
  replica-$VERSION-$PORT-3:
    container_name: replica-$VERSION-$PORT-3
    image: mongo:$VERSION
    volumes:
      - ./data/data3:/data/db
      - ./keyfile:/scripts/keyfile
    networks:
      - mongors-network-$PORT
    ports:
      - $PORT2:27017
    restart: always
    entrypoint: [ "/usr/bin/mongod", "--bind_ip_all", "--replSet", "rs0" ,"--keyFile","/scripts/keyfile"]

networks:
  mongors-network-$PORT:
    driver: bridge
EOF
) > $DIR/docker-compose.yml

# create rs-init.sh
(cat<<BOF
#!/bin/bash

mongo <<EOF
var config = {
    "_id": "rs0",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "replica-$VERSION-$PORT-1:27017",
            "priority": 3
        },
        {
            "_id": 2,
            "host": "replica-$VERSION-$PORT-2:27017",
            "priority": 2
        },
        {
            "_id": 3,
            "host": "replica-$VERSION-$PORT-3:27017",
            "priority": 1
        }
    ]
};
rs.initiate(config, { force: true });
rs.status();
EOF

mongo <<EOF
   for(i=0;i<1000;i++){
      if (!rs.isMaster().ismaster){
         sleep(1000);
         continue;
      }
   }
   use admin;
   admin = db.getSiblingDB("admin");
   admin.createUser(
     {
        user: "$USER",
        pwd: "$PWD",
        roles: [ { role: "root", db: "admin" } ]
     });
     db.getSiblingDB("admin").auth("$USER", "$PWD");
EOF
BOF
) > $DIR/rs-init.sh
chmod +x $DIR/rs-init.sh


# create stop.sh
STOPFILE=stop-$VERSION-$PORT.sh
(cat<<EOF
#!/bin/bash
(cd $DIR && docker-compose down)
rm -f \$0 && rm -fr $DIR
EOF
) > $STOPFILE
chmod +x $STOPFILE

# start 
(cd $DIR && docker-compose up -d && sleep 5 && docker exec replica-$VERSION-$PORT-1 /scripts/rs-init.sh)
