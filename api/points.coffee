# modules
User = require '../models/user'
Team = require '../models/team'
Game = require '../models/game'
Point = require '../models/point'
GamePoint = require '../models/game_point'
GameController = require '../controllers/game_controller'

# CONTROLLER
# ----------
module.exports = (app) ->


    # GET /api/points
    app.get '/api/points', 'points.list', (req, res) ->
        list = []
        Point.findAll().then (points) ->
            list.push formatPoint(point) for point in points
            res.json list

    # GET /api/points/:id/check
    app.get '/api/points/:code/check', (req, res) ->
        return unless req.checkAuthentication()
        useGPS = true
        if !req.query.lat  || !req.query.lng
            useGPS = false
            console.log "/points/check/#{req.params.code} user: #{req.session.user.id} without GPS"
        else
            lat = parseFloat (req.query.lat).replace(',', '.')
            lng = parseFloat (req.query.lng).replace(',', '.')
            console.log "/points/check/#{req.params.code} user: #{req.session.user.id} @ lat: #{lat} lng: #{lng}"

        User.findOne
            where: id: req.session.user.id
        .done (user) ->
            GameController.currentGame (current_game) ->
                Point.findOne
                    where: code: req.params.code
                .done (point) ->
                    GameController.checkPoint user, current_game, point, lat, lng, useGPS,(game_user, game_team, game_point) ->
                        res.json
                            game_user: game_user
                            game_team: game_team
                            game: current_game
                            game_point: game_point

    # GET /api/points/:id
    app.get '/api/points/:id', (req, res) ->
        GameController.currentGame (current_game) ->
            if current_game == null
                message = 'No current game.'
                res.genericError message, 'NotFoundError', 404
            else
                selectGamePointFromReq req.params.id, current_game.id, (game_point) ->
                    if game_point then res.json formatGamePoint(game_point)
                    else res.notFoundError()

# METHODS
# -------

formatPoint = (point) ->
    result = point
    return result

formatGamePoint = (game_point) ->
    result = game_point
    return result

selectGamePointFromReq = (pointId, gameId, callback) ->
    GamePoint.findOne
        where:
            pointId: pointId
            gameId: gameId
    .done callback
