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
#   sh sqlrun.sh
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
CONTAINER_NAME=pammy-sql
 
# the path to the persistent volume in the docker host and container
CONTAINER_VOLUME_PATH=/var/lib/mysql/pamm

IS_RHEL=$(grep rhel /etc/os-release -c)

if [[ ${IS_RHEL} = 0 ]]; then
    echo 'WARNING: This script has been tested with RHEL 7 like hosts only.'
fi

# checks if mysql client is installed and if not, triggers its installation
check_for_mysql_client() {
    a=$(rpm -q mysql | grep -c 'not installed')
    if [[ ${a} = 1 ]]; then
        echo 'Installing mysql client tools, please wait'
        sudo yum install mysql -y
    fi
}

# waits for mysql to become available on localhost
wait_for_mysql_server() {
  printf "mysql starting: please wait "
  until mysqladmin -u root -pn3us -s -h 127.0.0.1 ping; do
   printf "."
   sleep 2
  done
  printf "\n"
}

echo 'Creating SQL data files location on the host'
# removes any previous volume folder
sudo rm -rf ${CONTAINER_VOLUME_PATH}
# creates a  fresh volume folder
sudo mkdir -p ${CONTAINER_VOLUME_PATH}

# if the container exists, removes it
container_exists=$(docker ps -a -f name=${CONTAINER_NAME} | grep ${CONTAINER_NAME} -c)
if [[ ${container_exists} = 1 ]]; then
   echo 'Removing existing '${CONTAINER_NAME}' container'
   docker rm -f ${CONTAINER_NAME}
fi

echo 'Creating a new '${CONTAINER_NAME}' container'
docker run --name ${CONTAINER_NAME} -v ${CONTAINER_VOLUME_PATH}:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=${DB_PWD} -p ${DB_PORT}:3306 -d mariadb:${MARIA_TAG}

# check if the mysql client tools are installed
check_for_mysql_client

# wait for the service in the container to start
wait_for_mysql_server

echo 'Creating the '${DB_NAME}' database'
docker exec "${CONTAINER_NAME}" /bin/sh -c "mysql -uroot -p${DB_PWD} -e 'create database "${DB_NAME}";'"

echo 'Creating the '${DB_USER_NAME}' user'
docker exec $CONTAINER_NAME /bin/sh -c "mysql -uroot -p${DB_PWD} -e 'grant all privileges on ${DB_NAME}.* to '\''${DB_USER_NAME}'\''@'\''%'\'' identified by '\''${DB_PWD}'\'';'"

echo 'Copying the sql script to the container'
docker cp ${DB_SCHEMA_PATH} ${CONTAINER_NAME}:/db.sql

echo 'Creating the database tables and referencial integrity'
docker exec ${CONTAINER_NAME} bash -c "mysql -uroot -p${DB_PWD} ${DB_NAME} < db.sql"
