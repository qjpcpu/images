#!/bin/bash
docker run -d --name my-auditpg11 --rm -p 65432:5432 -e POSTGRESQL_USERNAME=root -e POSTGRESQL_PASSWORD=pwd -e POSTGRESQL_DATABASE=mydb  -e POSTGRESQL_PGAUDIT_LOG=all -e POSTGRESQL_WAL_LEVEL=logical bitnami/postgresql:11
