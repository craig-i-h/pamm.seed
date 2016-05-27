#!/bin/bash
#
# Copyright 2016 - gatblau.org
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Creates a MariaDb based sql database running on a Docker container.
# Usage:
#   sh pamm-sql.sh
#

# the version of the MariaDb docker image to use
MARIA_TAG=latest

# the db password
DB_PWD=n3us

# the name of the user to have db access
DB_USER_NAME=pamm

# the name of the db to be created
DB_NAME=pamm

# the db port to use
DB_PORT=3306

# the path to the database schema file to use to createthe application tables
DB_SCHEMA_PATH=svc/conf/evolutions/default/1.sql

# the name of the pamm db container to be created
CONTAINER_NAME=pamm-sql
 
# the path to the persistent volume in the docker host and container
CONTAINER_VOLUME_PATH=/var/lib/mysql

# check if the db container is running
up=$(docker ps -a --filter name=$CONTAINER_NAME | grep -c Up)

# check if the db container is stopped
exited=$(docker ps -a --filter name=$CONTAINER_NAME | grep -c Exited)

if [[ up -eq 0 ]] && [[ exited -eq 0 ]]; then  
  if [[ ! -d "$CONTAINER_VOLUME_PATH" ]]; then
    echo 'Creating SQL data files location on the host'
    sudo mkdir ${CONTAINER_VOLUME_PATH}
  fi
  echo 'No container found - creating pamm-sql container'
  docker run --name ${CONTAINER_NAME} -v ${CONTAINER_VOLUME_PATH}:${CONTAINER_VOLUME_PATH} -e MYSQL_ROOT_PASSWORD=${DB_PWD} -p ${DB_PORT}:3306 -d mariadb:${MARIA_TAG}

  echo 'Creating the PAMM database'
  a=(docker exec -it ${CONTAINER_NAME} bash -c "mysql -uroot -p${DB_PWD} -e 'create database ${DB_NAME};'")

  echo 'Creating the PAMM user'
  a=(docker exec $CONTAINER_NAME bash -c "mysql -uroot -p${DB_PWD} -e 'grant all privileges on ${DB_NAME}.* to '\''${DB_USER_NAME}'\''@'\''%'\'' identified by '\''${DB_PWD}'\'';'")

  echo 'Copying the pamm sql script to the container'
  docker cp ${DB_SCHEMA_PATH} ${CONTAINER_NAME}:/db.sql

  echo 'Creating the database tables and referencial integrity'
  a=(docker exec ${CONTAINER_NAME} bash -c "mysql -uroot -p${DB_PWD} ${DB_NAME} < db.sql")
elif [[ exited -eq 0 ]]; then
  echo 'pamm-sql is already running!'
else
  echo 'pamm-sql exists but is not running - starting pamm-sql'
  docker start ${CONTAINER_NAME}
fi
