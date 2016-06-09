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

# wait for the server process to open a listening socket on the specified port
# usage example:
#    wait_for_port 8080
wait_for_port() {
  while netstat -lnt | awk '$4 ~ /:'${1}'$/ {exit 1}'; do sleep 10; done
}

# prints to the output in color
print() {
    CYAN='\033[0;36m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
    printf "${CYAN}$(date +"%T") -> ${YELLOW}${1}${NC}\n"
}

startTime=$(date -u +"%s")

DIR=$PWD

# configure ports to use
APP_PORT=8080
SQL_PORT=3306
TEST_SETUP_PORT=8081
SELENIUM_PORT=4444

print "Current directory is $DIR"

print "Cleaning up any existing processes"
sh shutdown.sh ${APP_PORT} ${TEST_SETUP_PORT} ${SELENIUM_PORT}

print "Initialising MariaDb"
sh sqlrun.sh

print "Packaging the PAMM application"
activator svc/assembly

cd $DIR/svc/target/scala-2.11

print "Launching the PAMM application on port ${APP_PORT}"
exec java -jar -Dhttp.port=${APP_PORT} -Ddb.default.url="jdbc:mysql://localhost:${SQL_PORT}/pamm?useUnicode=true&characterEncoding=utf8" svc-assembly-0.0.1-SNAPSHOT.jar &

wait_for_port ${APP_PORT}

cd $DIR
print "Packaging the TEST SETUP application"
activator testsetup/assembly

cd testsetup/target/scala-2.11

print "Launching the TEST SETUP application on port ${TEST_SETUP_PORT}"
exec java -jar -Dhttp.port=${TEST_SETUP_PORT} -Ddb.default.url="jdbc:mysql://localhost:${SQL_PORT}/pamm?useUnicode=true&characterEncoding=utf8" testsetup-assembly-0.0.1-SNAPSHOT.jar &

wait_for_port ${TEST_SETUP_PORT}

cd $DIR
print "Installing the required Javascript packages"
npm install

print "Updating the Seleniun web driver"
npm run webdriver-update

print "Starting the Selenium server"
node_modules/.bin/webdriver-manager start &

wait_for_port ${SELENIUM_PORT}

print "Running the feature tests"
sh testrun.sh


endTime=$(date -u +"%s")
diff=$(($endTime-$startTime))

print "Build & Test process complete: it took $(($diff / 60)) minutes and $(($diff % 60)) seconds."