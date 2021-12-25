#!/bin/bash

USER=root
PWD=pwd

mongo <<EOF
var config = {
    "_id": "rs0",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "mongo1:27017",
            "priority": 3
        },
        {
            "_id": 2,
            "host": "mongo2:27017",
            "priority": 2
        },
        {
            "_id": 3,
            "host": "mongo3:27017",
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


