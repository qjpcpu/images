#!/bin/bash
docker run --name mypostgres11 --rm -p  15432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=pwd -e POSTGRES_DB=mydb  -e PGDATA=/var/lib/postgresql/data/pgdata -v $PWD/data:/var/lib/postgresql/data -d postgres:11 postgres -c wal_level=logical
