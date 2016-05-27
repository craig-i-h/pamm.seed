#!/bin/env bash
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
# Compiles, packages and starts the pamm application.
# Usage:
#   sh apprun.sh
#

# $1: port e.g. 8080
# $2: path to PID file e.g. svc/target/universal/svc-0.0.1-SNAPSHOT/RUNNING_PID
free_port() {
    port="lsof -iTCP:${1}"
    if [[ ! -z "${port}" ]]; then
       echo "Port ${1} in use, killing related process"
       fuser -k "${1}"/tcp
    fi
    if [[ ! -z $2 ]] && [[ -f $2 ]]; then
       echo "Removing RUNNING_PID file in $2"
       rm "${2}"
    fi
}

# wait for the server process to open a listethe specified port
# usage:
# wait_for_port 8080
wait_for_port() {
  while netstat -lnt | awk '$4 ~ /:'${1}'$/ {exit 1}'; do sleep 10; done
}

print() {
    CYAN='\033[0;36m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
    printf "${CYAN}$(date +"%T") -> ${YELLOW}${1}${NC}\n"
}

DIR=$PWD
APP_PORT=8080
SQL_PORT=3306
TEST_SETUP_PORT=8081
SELENIUM_PORT=4444

print "Current directory is $DIR"

print "Killing previous applications listening on required ports"
free_port ${APP_PORT} "svc/target/universal/svc-0.0.1-SNAPSHOT/RUNNING_PID"
free_port ${TEST_SETUP_PORT} "testsetup/target/universal/testsetup-0.0.1-SNAPSHOT/RUNNING_PID"

fuser -k ${SELENIUM_PORT}/tcp

print "Initialising MariaDb"
sh sqlrun.sh

print "Packaging the PAMM application"
activator svc/dist

cd $DIR/svc/target/universal
unzip -o svc-0.0.1-SNAPSHOT.zip
rm svc-0.0.1-SNAPSHOT.zip
export APP_DIR=svc-0.0.1-SNAPSHOT

print "Launching the PAMM application on port ${APP_PORT}"
exec java -cp "$APP_DIR/lib/*" -Dhttp.port=${APP_PORT} -Ddb.default.url="jdbc:mysql://localhost:${SQL_PORT}/pamm?useUnicode=true&characterEncoding=utf8" play.core.server.ProdServerStart $APP_DIR &

wait_for_port ${APP_PORT}

cd $DIR
print "Packaging the TEST SETUP application"
activator testsetup/dist

cd testsetup/target/universal
unzip -o testsetup-0.0.1-SNAPSHOT.zip
rm testsetup-0.0.1-SNAPSHOT.zip
export TEST_SETUP_DIR=testsetup-0.0.1-SNAPSHOT

print "Launching the TEST SETUP application on port ${TEST_SETUP_PORT}"
exec java -cp "$TEST_SETUP_DIR/lib/*" -Dhttp.port=${TEST_SETUP_PORT} -Ddb.default.url="jdbc:mysql://localhost:${SQL_PORT}/pamm?useUnicode=true&characterEncoding=utf8" play.core.server.ProdServerStart $TEST_SETUP_DIR &

wait_for_port ${TEST_SETUP_PORT}

cd $DIR
print "Installing the required Javascript packages"
npm install

print "Updating the Seleniun web driver"
npm run webdriver-updateclear

print "Installing the Selenium server"
node_modules/.bin/webdriver-manager start &

wait_for_port ${SELENIUM_PORT}

print "Running the feature tests"
sh testrun.sh