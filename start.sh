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
#   sh start.sh
#
echo initialising the pamm-sql databale
sh pamm-sql.sh

echo creating a distribution for the PAMM application
activator svc/dist

echo preparing and launching the PAMM application
cd svc/target/unviversal
unzip svc-0.0.1-SNAPSHOT.zip & rm svc-0.0.1-SNAPSHOT.zip
export PLAY_DIR=svc-0.0.1-SNAPSHOT
(java -cp "$PLAY_DIR/lib/*" -Dhttp.port=8080 -Ddb.default.url="jdbc:mysql://localhost:3306/pamm?useUnicode=true&characterEncoding=utf8" play.core.server.ProdServerStart $PLAY_DIR)

echo creating a distribution for the TestSetup service
activator testsetup/dist

echo preparing and launching the TestSetup application
cd testsetup/target/universal
unzip testsetup-0.0.1-SNAPSHOT.zip & testsetup-0.0.1-SNAPSHOT.zip
export TEST_SETUP_DIR=testsetup-0.0.1-SNAPSHOT
java -cp "$TEST_SETUP_DIR/lib/*" -Dhttp.port=8081 -Ddb.default.url="jdbc:mysql://localhost:3306/pamm?useUnicode=true&characterEncoding=utf8" play.core.server.ProdServerStart $TEST_SETUP_DIR &

echo installing PAMM application Javascript packages
npm install

echo updating the seleniun web driver
npm run webdriver-up

echo installing the selenium server
node_modules/.bin/webdriver-manager start

echo starting the execution of tests
node_modules/.bin/protractor --params.testsetupurl="http://localhost:8081" svc/test/webapp/e2e_test/feature/all-tests.conf.js