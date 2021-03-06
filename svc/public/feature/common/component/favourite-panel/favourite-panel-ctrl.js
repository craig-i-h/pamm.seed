"use strict";

angular.module("pamm").controller("favouritePanelCtrl", ["$scope", "$log", "userContext",
    function ($scope, $log, userContext) {
        var vm = this;

        vm.favouriteProjects = userContext.getFavouriteProjects();

        vm.isSelected = function (project) {
            var selectedProject = userContext.getSelectedProject();
            return (!!selectedProject && selectedProject.id == project.id);
        };

        vm.setAsSelected = function (project) {
            userContext.setSelectedProject(project);
        };

        vm.removeFavourite = function (project) {
            $$dialog.confirm("Are you sure that you want to remove " + project.title + " from the favourite list?", "Remove",
                function () {
                    userContext.removeFavourite(project);
                    $scope.$apply();
                });
        };

        $log.info("favouritePanelCtrl: instantiated");
    }]);
