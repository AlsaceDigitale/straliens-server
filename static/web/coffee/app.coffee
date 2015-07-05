@App = angular.module 'straliens', ['ui.router', 'uiGmapgoogle-maps', 'ui.bootstrap', 'ngCookies', 'cgNotify', 'qrScanner']
serverUrl = 'http://' + location.host
wsUrl = 'ws://' + location.host

App.factory 'authInterceptor', [
    '$rootScope'
    '$q'
    ($rootScope, $q) ->
        return {
            request: (config) ->
                return config
            response: (res) ->
                if res.status == 401
                    # Need to reconnect
#                    if localStorage.user
#                    else
                    delete localStorage.user
                    console.log 'error'
                return res or $q.when(res)
        }
]

App.config [
    '$httpProvider'
    ($httpProvider) ->
        # Check for bad auth
        $httpProvider.interceptors.push 'authInterceptor'

        # Use x-www-form-urlencoded Content-Type
        $httpProvider.defaults.headers.post['Content-Type'] = 'application/x-www-form-urlencoded;charset=utf-8'

        ###*
        # converts an object to x-www-form-urlencoded serialization.
        # @param {Object} obj
        # @return {String}
        ###
        param = (obj) ->
            query = ''
            name = undefined
            value = undefined
            fullSubName = undefined
            subName = undefined
            subValue = undefined
            innerObj = undefined
            i = undefined
            for name of obj
                value = obj[name]
                if value instanceof Array
                    i = 0
                    while i < value.length
                        subValue = value[i]
                        fullSubName = name + '[' + i + ']'
                        innerObj = {}
                        innerObj[fullSubName] = subValue
                        query += param(innerObj) + '&'
                        ++i
                else if value instanceof Object
                    for subName of value
                        subValue = value[subName]
                        fullSubName = name + '[' + subName + ']'
                        innerObj = {}
                        innerObj[fullSubName] = subValue
                        query += param(innerObj) + '&'
                else if value != undefined and value != null
                    query += encodeURIComponent(name) + '=' + encodeURIComponent(value) + '&'
            if query.length then query.substr(0, query.length - 1) else query

        # Override $http service's default transformRequest
        $httpProvider.defaults.transformRequest.push (data) ->
            if data
                data = JSON.parse data
                delete data.urlEncoded
                param(data)
            else
                data
]

App.config [
    '$stateProvider'
    '$urlRouterProvider'
    ($stateProvider, $urlRouterProvider) ->
        $urlRouterProvider.otherwise '/'

        $stateProvider
        .state 'play',
            url: '/'
            controller: [
                '$rootScope'
                '$state'
                ($rootScope, $state) ->
                    $rootScope.checkUserOrReconnect()
                        .then ->
                            if !$rootScope.currentGame then $state.go 'nogame'
                        , ->
                                $state.go 'login'
            ]

        .state 'login',
            url: '/login'
            controller: 'loginCtrl'
            title: 'Login'
            templateUrl: '/partials/login.html'

        .state 'signup',
            url: '/signup'
            controller: 'signupCtrl'
            title: 'SignUp'
            templateUrl: '/partials/signup.html'

        .state 'check',
            url: '/check/:id'
            controller: 'checkCtrl'
            title: 'check'
            templateUrl: '/partials/check.html'

        .state 'scan',
            url: '/scan'
            controller: 'scanCtrl'
            title: 'scan qr code'
            templateUrl: '/partials/scan.html'

        .state 'nogame',
            url: '/nogame'
            controller: 'nogameCtrl'
            title: 'no game'
            templateUrl: '/partials/nogame.html'


        .state 'endgame',
            url: '/endgame'
            controller: 'endgameCtrl'
            title: 'end game'
            templateUrl: '/partials/endgame.html'
]

App.factory 'GeolocationService', [
    '$q'
    '$window'
    '$rootScope'
    ($q, $window, $rootScope) ->
        ->
            deferred = $q.defer()
            if !$window.navigator
                $rootScope.$apply ->
                    deferred.reject new Error('Geolocation is not supported')
            else
                $window.navigator.geolocation.getCurrentPosition ((position) ->
                    $rootScope.$apply ->
                        deferred.resolve position
                ), (error) ->
                    $rootScope.$apply ->
                        deferred.reject error
            deferred.promise
]

# Scan controller
# ---------------
App.controller 'scanCtrl', [
    '$rootScope'
    '$scope'
    '$state'
    '$q'
    ($rootScope, $scope, $state, $q) ->
        $scope.videoSources = []

        $scope.onSuccess = (data) ->
            $scope.data = data
            if data.indexOf 'tc3.fr' > -1
                document.location = data.toString()

        $scope.onError =  ->
            alert "Vous avez refusé l'accès à la camera"
            $state.go 'play'

        # Get available video sources on modern browsers
        $scope.videoSources = $q (resolve) ->
            if typeof MediaStreamTrack == 'undefined' || typeof MediaStreamTrack.getSources == 'undefined'
                console.log 'This browser does not support MediaStreamTrack'
                resolve(['Camera'])
            else
                MediaStreamTrack.getSources (sources) ->
                    videoSources = []
                    i = 1
                    for source in sources
                        if (source.kind == 'video')
                            source.n = i
                            i++
                            if source.facing is 'user' then source.name = 'frontale'
                            else if source.facing is 'environment' then source.name = 'arrière'
                            videoSources.push source
                    resolve videoSources
]


# Check controller
# ---------------
App.controller 'checkCtrl', [
    '$rootScope'
    '$scope'
    '$http'
    '$state'
    'GeolocationService'
    ($rootScope, $scope, $http, $state, geolocation) ->
        # TODO: geoloc
        $rootScope.checkUserOrReconnect()
        .then ->
            $http
                url: serverUrl + "/api/points/#{$state.params.id}/check/"
                method: 'GET'
                withCredentials: true

            .success (data) ->
                $rootScope.energy = 0
                $state.go 'play'
        , ->
            $state.go 'login'


]

# Notify controller
# -----------------
App.controller 'notifCtrl', [
    '$scope'
    'notify'
    ($scope, notify) ->
        notify.config {startTop : 0, maximumOpen: 3, templateUrl: "/resources/angular-notify-custom.html"}    
        $scope.shownotify = ->
            notify "Hello there" 
]

App.controller 'chat', [
    '$scope'
    ($scope) ->
        $scope.chatClass = ""
        $scope.tab = "room"

        $scope.open = () ->
            if $scope.chatClass == 'toggled'
              $scope.chatClass = ''
            else
              $scope.chatClass = 'toggled'

        $scope.openTab = (tab) ->
            alert tab
            $scope.tab = tab

]
    
# Index page controller
# ---------------------
App.controller 'playCtrl', [
    '$rootScope'
    '$scope'
    '$http'
    '$state'
    'uiGmapIsReady'
    '$timeout'
    ($rootScope, $scope, $http, $state, uiGmapIsReady, $timeout) ->

        # Get all the points
        $http.get serverUrl + "/api/points"
        .success (data) ->
            $rootScope.points = data
            $rootScope.points.forEach (point) ->
                $http.get serverUrl + "/api/points/"+ point.id
                .success (data) ->
                    point.coordinates = { latitude: point.lat, longitude: point.lng }
                    if data.type == 'cathedrale'
                        point.options = {
                            labelContent: Math.abs(data.energy) || '0'
                            labelClass: 'map-label-cathedrale'
                        }
                    else
                        point.options = {
                            labelContent: Math.abs(data.energy) || '0'
                            labelClass: 'map-label side-' + data.side
                        }
                    point.icon =
                        path: ''
                    point.data = data

        initGame = ->
            $rootScope.checkUserOrReconnect()
            .then ->
                # if valid user, check if there is a game running
                $http.get serverUrl + '/api/games/current'
                .success (game) ->
                    $rootScope.currentGame = game

                    # Get user's side
                    $http
                        url: serverUrl + "/api/users/#{$rootScope.user.id}/side"
                    .success (side) ->
                        if side == "EARTHLINGS" then side = "TERRIENS"
                        $rootScope.side = side


                    # Manage the clock
                    fnTimeout = () ->
                        time = (new Date(game.endTime) - new Date(Date.now()))

                        diff = Math.floor(time / 1000)
                        secs_diff = diff % 60
                        diff = Math.floor(diff / 60)
                        mins_diff = diff % 60
                        diff = Math.floor(diff / 60)
                        hours_diff = diff
                        diff = Math.floor(diff / 24)

                        $rootScope.endTime = if time > 0 then "#{(if hours_diff<10 then '0' else '') + hours_diff}:#{(if mins_diff<10 then '0' else '') + mins_diff}:#{(if secs_diff<10 then '0' else '') + secs_diff}" else "00:00:00"
                        if time > 0
                            $rootScope.hourTimeout  = $timeout fnTimeout, 1000
                        else
                            $state.go 'endgame'
                    $rootScope.hourTimeout  = $timeout fnTimeout, 1000
            , ->
                $state.go 'login'

        initGame()

        $scope.map =
            zoom: 15
            center:
                #center on cathedrale
                latitude: 48.5819
                longitude: 7.75104
            options:
                minZoom: 13
                maxZoom: 20
                panControl: false
                zoomControl: true
                mapTypeControl: false
                scaleControl: false
                streetViewControl: false
                overviewMapControl: false
                mapTypeControl: false
            control: {}
            events:
                center_changed: (map) ->
                    allowedBounds =
                        sw: [48.572579, 7.732542]
                        ne: [48.589705, 7.775301]
                    C = map.getCenter()
                    if C.lng() > allowedBounds.ne[1] || C.lng() < allowedBounds.sw[1] || C.lat() > allowedBounds.ne[0] || C.lat() < allowedBounds.sw[0]
                        X = C.lng()
                        Y = C.lat()

                        AmaxX = allowedBounds.ne[1]
                        AmaxY = allowedBounds.ne[0]
                        AminX = allowedBounds.sw[1]
                        AminY = allowedBounds.sw[0]

                        if (X < AminX)
                            X = AminX
                        if (X > AmaxX)
                            X = AmaxX
                        if (Y < AminY)
                            Y = AminY
                        if (Y > AmaxY)
                            Y = AmaxY

                        map.panTo {lat: Y, lng: X}

        # Wait for the map to be ready before binding the socket's event
        uiGmapIsReady.promise().then ->
            $rootScope.socket.on 'score:update', (userScore, teamScore) ->
                $rootScope.score = userScore
                $rootScope.teamScore = teamScore
                $rootScope.$apply()

            $rootScope.socket.on 'point:update', (data) ->
                point = p for p in $scope.points when p.id == data.point.id
                if point
                    point.options = {
                        labelAnchor: '0 0'
                        labelContent: Math.abs(data.gamePoint.energy) || '0'
                        labelClass: 'map-label side-' + data.gamePoint.side
                    }
                    point.data = data.gamePoint

            $rootScope.socket.on 'user:update', (data) ->
                if data.energy then $rootScope.energy = data.energy
                $rootScope.$apply()
]

App.controller 'loginCtrl', [
    '$rootScope'
    '$scope'
    '$state'
    '$http'
    ($rootScope, $scope, $state, $http) ->
        $rootScope.checkUserOrReconnect()
        .then ->
            $state.go 'play'
            window.location.reload false
        , null

        $scope.validate = (form) ->
            $rootScope.login
                nickname: form.nickname
                password: form.password
            .success (user) ->
                $state.go 'play'
                window.location.reload false
            .error (err) ->
                if err.type == 'AuthenticationError'
                    $scope.error = true
]


App.controller 'signupCtrl', [
    '$rootScope'
    '$scope'
    '$state'
    '$http'
    ($rootScope, $scope, $state, $http) ->
        $scope.teams = []

        $scope.errors = {}

        $scope.resultTeam =
            name: ''
            pwd: ''
            slogan: ''

        $http.get serverUrl + "/api/teams"
        .success (data) ->
            $scope.teams = data

        $scope.team = ->
            return team for team in $scope.teams when team.name.toLowerCase() == ($scope.resultTeam.name || '').toLowerCase()

        $scope.create = (form) ->
            createUser = (user) ->
                $http
                    url: serverUrl + '/api/users?sections=team',
                    method: "POST"
                    withCredentials: true

                    data:
                        nickname: user.nickname
                        email: user.email
                        password: user.password
                        teamPassword: user.teamPassword
                        teamId: user.teamId
                .success (data) ->
                    user =
                        id: data.id
                        name: data.nickname
                        teamId: data.teamId
                        team: data.team
                        password: form.password
                    $rootScope.user = user
                    saveUser user

                    $rootScope.updateVitals()

                    $rootScope.socket.disconnect()
                    $rootScope.socket = io wsUrl

                    $state.go 'play'
                    window.location.reload false
                .error (data) ->
                    data.fields.forEach (err) ->
                        $scope.errors[err.path] = err.message

            if !$scope.team()
                $http.post serverUrl + '/api/teams',
                    name: $scope.resultTeam.name
                    slogan: $scope.resultTeam.slogan
                    password: $scope.resultTeam.password
                .success (team) ->
                    $scope.team = ->
                        return team

                    user =
                        nickname: form.nickname.$viewValue
                        email: form.email.$viewValue
                        password: form.password.$viewValue
                        teamPassword: form.teamPassword.$viewValue
                        teamId: team.id
                    createUser(user)

            else
                user =
                    nickname: form.nickname.$viewValue
                    email: form.email.$viewValue
                    password: form.password.$viewValue
                    teamPassword: form.teamPassword.$viewValue
                    teamId: $scope.team().id
                createUser(user)
]

App.controller 'nogameCtrl', [
    '$rootScope'
    '$scope'
    '$state'
    '$http'
    ($rootScope, $scope, $state, $http) ->
        displayNextGames = ->
            $http.get serverUrl + '/api/games'
            .success (games) ->
                $scope.games = []
                for game in games when new Date(game.startTime) <= new Date Date.now()
                    game.startDate = moment(new Date(game.startTime)).format "dddd Do MMMM HH:mm"
                    game.endDate = moment(new Date(game.endTime)).format "HH:mm"
                    games.push game

        $rootScope.checkUserOrReconnect()
        .then ->
            $http.get serverUrl + '/api/games/current'
            .success (game) ->
                $rootScope.currentGame = game
                $state.go 'play'
            .error ->
                displayNextGames()
        , ->
            displayNextGames()
]


App.controller 'endgameCtrl', [
    '$rootScope'
    '$scope'
    '$state'
    '$http'
    ($rootScope, $scope, $state, $http) ->
        $rootScope.checkUserOrReconnect()
        .success ->

        if !$rootScope.validUser()
            $state.go 'login'

        $http.get serverUrl + '/api/games/current'
        .success (game) ->
            $scope.data = game
        .error (data) ->
            #$state.go 'nogame'
]

# RUN !!
# ------
App.run [
    '$rootScope'
    '$state'
    '$window'
    '$http'
    'notify'
    '$q'
    ($rootScope, $state, $window, $http, notify, $q) ->
        $rootScope.$state = $state
        $rootScope.$http = $http

        $rootScope.endTime = '00:00:00'
        $rootScope.score = null
        $rootScope.energy = null
        $rootScope.teamScore = null

        $rootScope.user = {}
        # Auto update stored user data

        $rootScope.side = 'NEUTRE'

        $rootScope.points = {}

        # Check if user should have a session or reconnect him if still in localStorage
        $rootScope.checkUserOrReconnect = ->
            $q (resolve, reject) ->
                $http
                    url: serverUrl + '/api/services/logged-in'
                    withCredentials: true
                .success (status) ->
                    if localStorage.user
                        user = JSON.parse localStorage.user
                        if status == true and angular.isObject user
                            $rootScope.user = user
                            saveUser user
                            resolve(user)
                        else
                            $rootScope.login
                                nickname: user.nickname
                                password: user.password
                            .success (user) ->
                                resolve(user)
                            .error ->
                                reject()
                                delete localStorage.user
                    else
                        delete localStorage.user
                        reject()

        # Handle websockets
        $rootScope.socket = io wsUrl
        $rootScope.socket.on 'notification:send', (data) ->
            notify "Hello there "+data

        # Login with user.nickname and user.password
        # Store user in localStorage then update some infos
        # Reconnect to the socket with the new session
        $rootScope.login = (user) ->
            $http
                url: serverUrl + "/api/services/login?sections=team",
                method: "POST"
                withCredentials: true
                data:
                    nickname: user.nickname
                    password: user.password
                    urlEncoded: true
            .success (res) ->
                res.password = user.password

                $rootScope.user = res
                saveUser res

                $rootScope.updateVitals()

                $rootScope.socket.disconnect()
                $rootScope.socket = io wsUrl


        # Update user infos if there is a game running
        $rootScope.updateVitals = ->
            $http
                url: serverUrl + "/api/users/me",
                method: "GET"
                withCredentials: true
            .success (data) ->
                if data.gameUser
                    if data.gameUser.energy then $rootScope.energy = data.gameUser.energy
                    if data.gameUser.score then $rootScope.score = data.gameUser.score
                if data.gameTeam
                    if data.gameTeam.score then $rootScope.teamScore = data.gameTeam.score


        # Start something...
        # Connect user if available and update all the infos
        $rootScope.checkUserOrReconnect()
        .then ->
            $rootScope.updateVitals()
        , ->
            $state.go 'login'
]

saveUser = (user) ->
    localStorage.user = JSON.stringify user
