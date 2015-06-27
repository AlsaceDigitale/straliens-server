# modules
Points = require '../models/point'
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
        console.log "/points/check/#{req.params.code} user: #{req.query.user_id}"
        User.findOne
            where: id: req.query.user_id
        .done (user) ->
            GameController.currentGame (current_game) ->
                Points.findOne
                  where: code: req.params.code
                .done (point) ->
                    GameController.checkPoint user, current_game, point, (game_user, game_team, game_point) ->
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
    result.energy = Math.abs(result.energy)
    return result

selectGamePointFromReq = (pointId, gameId, callback) ->
    GamePoint.findOne
        where:
            pointId: pointId
            gameId: gameId
    .done callback
