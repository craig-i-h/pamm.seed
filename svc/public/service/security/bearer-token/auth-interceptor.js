// Using injector to locate services to avoid circular dependency on load for $http
angular.module("pamm").service("authInterceptor", ["$log", "$q", "$injector",
    function ($log, $q, $injector) {
        return {
            request: function (config) {
                var token = $injector.get("authService").getToken();
                if (token) {
                    config.headers.Authorization = "Bearer " + token;
                }
                return config || $q.when(config);
            },
            requestError: function (rejection) {
                return $q.reject(rejection);
            },
            response: function (response) {
                return response;

            },
            responseError: function (rejection) {
                var $state = $injector.get("$state");

                // check for expired reason

                if (rejection.status == $$httpStatus.UNAUTHORIZED) {
                    // check for expiry - if so re-authenticate

                    $injector.get("userContext").logout();
                    if ($state.current.name != "user.login") {
                        $state.go("user.login");
                    }
                } else if (rejection.status >= $$httpStatus.INTERNAL_ERROR) {
                    // Pass through to application
                }
                return $q.reject(rejection);
            }
        }
    }]).config(["$httpProvider",
    function ($httpProvider) {
        if (!$httpProvider.defaults.headers.get) {
            $httpProvider.defaults.headers.get = {};
        }
        // Prevent responses from being cached by the browser (specifically for Internet Explorer).
        $httpProvider.defaults.headers.get["Cache-Control"] = "no-cache";
        $httpProvider.defaults.headers.get["Pragma"] = "no-cache";
        $httpProvider.defaults.headers.get["Expires"] = "0";

        $httpProvider.interceptors.push("authInterceptor");
    }]);

