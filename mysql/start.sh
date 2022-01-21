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
DIR=$PWD/forks/$PORT
mkdir -p $DIR/conf
(cat<<EOF
[mysqld]
server-id = 1

binlog_format=row
log-error = /var/lib/mysql/mysqld.err
log-bin = /var/lib/mysql/binlog.log
port = 3306

enforce_gtid_consistency = ON
gtid_mode = ON
default_authentication_plugin=mysql_native_password
EOF
) > $DIR/conf/my.cnf

docker run -it --rm --name mysql-$VERSION-$PORT -p $PORT:3306 -v $DIR/conf:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=pwd -e MYSQL_DATABASE=mydb -d mysql:$VERSION --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci


STOPFILE=stop-$VERSION-$PORT.sh

echo '#!/bin/bash' > $STOPFILE
echo "docker stop mysql-$VERSION-$PORT" >> $STOPFILE
echo 'rm -f $0' >> $STOPFILE
echo "rm -fr $DIR" >> $STOPFILE
chmod +x $STOPFILE
