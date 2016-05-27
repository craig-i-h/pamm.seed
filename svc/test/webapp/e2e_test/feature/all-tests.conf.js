require("./setup/conf.js");

config = {
  seleniumAddress: 'http://localhost:4444/wd/hub',

  capabilities: {
    browserName: 'chrome'
  },

  // CHANGE this to test server
  baseUrl: "http://localhost:8080",

  params: {
    profile: "local",
    testMode: "single"
  },

  specs: [
    "../setup/setup-login.feature"
  ],

  onPrepare: function () {
    browser.driver.manage().window().setPosition(3841, 0);
    browser.driver.manage().window().setSize(1024, 600);
    global.EC = protractor.ExpectedConditions;

    chai = require('chai');
    chaiAsPromised = require("chai-as-promised");
    chai.use(chaiAsPromised);

    expect = chai.expect;
    assert = chai.assert;
    should = chai.should;
  },

  // set to "custom" instead of cucumber.
  framework: 'custom',

  // path relative to the current config file
  frameworkPath: '../../../../../node_modules/protractor-cucumber-framework',
};

config.cucumberOpts = {
  //format: "summary",
  require: [
    "./login/login.step.js"
  ]
};

config.specs = [
  "./login/login.feature"
];




exports.config = config;


