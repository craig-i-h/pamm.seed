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
# Runs the feature tests in the PAMM Application.
# Called from apprun.sh
#
# Prerequisites:
#   PAMM Application  running
#   TEST SETUP Application running
#   Selenium Web Server running
# See apprun.sh for details.
#
# Usage:
#   sh testrun.sh
#
node_modules/.bin/protractor --params.testsetupurl="http://localhost:8081" svc/test/webapp/e2e_test/feature/all-tests.conf.js