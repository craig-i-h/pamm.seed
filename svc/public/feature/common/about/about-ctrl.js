"use strict";

angular.module("pamm").controller("aboutCtrl", ["$scope", "$uibModalInstance", "$log",
    function ($scope, $uibModalInstance, $log) {
        var vm = $scope;
        var toggle = false;
        var audio = new Audio("feature/common/about/everything_is_awesome.m4a");

        vm.togglePlay = function () {
            toggle = !toggle;

            if (toggle) {
                audio.play();
            } else {
                audio.pause();
            }
        };

        vm.pausePlay = function () {
            audio.pause();
        };

        vm.ok = function () {
            audio.pause();
            $uibModalInstance.dismiss("OK");
        };
    }]);