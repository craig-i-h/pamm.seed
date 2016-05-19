"use strict";

module.exports = (function () {
    var request = require('request-promise');

    function SetupServiceCaller() {
    }

    SetupServiceCaller.prototype.update = function (name) {

        var pathUrl = getTestSetupUrl() + "/update/"  + name;

        // This returns a promise.  Use success call back to check database
        return request(pathUrl);
    };

    SetupServiceCaller.prototype.query = function (name) {

        var pathUrl = getTestSetupUrl() + '/query/' + name;

        // This returns a promise.  Use success call back to check database
        return request(pathUrl);
    };

    function getTestSetupUrl(){
        var testSetupURL = browser.params.testsetupurl;
        if (testSetupURL == null || testSetupURL == undefined){
            //Set to default value
            testSetupURL = "http://localhost:9001";
        }

        return testSetupURL;
    }

    return SetupServiceCaller;
})();
