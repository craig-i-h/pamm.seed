"use strict";

module.exports = function loginTest() {
    var LoginPage = require("./login.page.js");
    var testData = require("./login-data.json");
    var SetupServiceCaller = require("../setup/setup-service-caller.js");
    var db = new SetupServiceCaller();

    /*************************
    /* pass in test data here using param in command line
    /*/
    console.log("+++++" + browser.params.testMode);

    var login = new LoginPage;
    var test = this;

    this.setDefaultTimeout(60000);
    db.update("login-test.sql");

    test.Given(/I am on the login view at the start/, function () {
        login.visitPage();

    });

    test.Then("There are no error messages on the page", function () {
        expect(login.invalidLoginError.isDisplayed()).to.eventually.be.false;
        expect(login.usernameRequiredError.isPresent()).to.eventually.be.false;
        expect(login.passwordRequiredError.isPresent()).to.eventually.be.false;
    });

        test.Given("I try to login without entering any credentials", function () {
        login.login();
    });

    test.Then("I stay at the login view and I see an error for missing credentials", function () {
        //expect(login.currentURL()).to.eventually.equal(testData.loginURL);
    });

    test.Given("I login with invalid credentials", function (next) {
        login.fillInDetails(testData.userName, testData.incorrectPassword);
        login.login().then(function () {
            next();
        });
    });

    test.Then("I stay at the login view and I see an error for invalid credentials", function () {
        //expect(login.currentURL()).to.eventually.equal(testData.loginURL);
        expect(login.invalidLoginError.isDisplayed()).to.eventually.be.true;
    });

    test.Given("I login with valid credentials", function (next) {
        login.fillInDetails(testData.userName, testData.password);
        login.login().then(function () {
            next();
        });
    });

    test.Then("I see the home page", function () {
        //expect(login.currentURL()).to.eventually.equal(testData.homeURL);
    });
};
