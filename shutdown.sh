#!/usr/bin/env bash
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
#   sh shutdown.sh APP_PORT, TEST_SETUP_PORT, SELENIUM_PORT
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

free_port ${1} "svc/target/universal/svc-0.0.1-SNAPSHOT/RUNNING_PID"
free_port ${2} "testsetup/target/universal/testsetup-0.0.1-SNAPSHOT/RUNNING_PID"

fuser -k ${3}/tcp