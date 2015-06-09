@App = angular.module 'straliens', ['ui.router', 'ngMap']

App.config [ -> ]

App.config ($stateProvider, $urlRouterProvider) ->
    $urlRouterProvider.otherwise '/play'

    $stateProvider
        .state 'login',
            url: '/login'
            controller: 'loginCtrl'
            title: 'Accueil'
            templateUrl: 'partials/login.html'

        .state 'play',
            url: '/play'
            controller: 'playCtrl'
            title: 'Accueil'
            templateUrl: 'partials/play.html'


# Main controller
# ---------------
App.controller 'AppController', [
    '$scope'
    ($scope) ->
]

# Index page controller
# ---------------------
App.controller 'playCtrl', [
    '$scope'
    '$state'
    ($scope, $state) ->
        $scope.$on 'mapInitialized', (event, map) ->

        $scope.map =
            center:
                latitude: 48.5803
                longitude: 7.7536
            zoom: 15
]

# RUN !!
# ------
App.run [
    '$rootScope'
    '$state'
    ($rootScope, $state) ->
        $rootScope.$state = $state
        # TODO: récupérer le temps restant
        $rootScope.endTime = '00H00'
        $rootScope.user =
            team: 'straliens'
            score: 0
            energy: 0
]
