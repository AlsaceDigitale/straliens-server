# modules
Points = require '../models/point'
User = require '../models/user'
Team = require '../models/team'
Game = require '../models/game'
Point = require '../models/point'
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
        user_id = req.query.user_id
        User.findOne
            where: id: user_id
        .done (user) ->
            GameController.currentGame (current_game) ->
                Points.findOne
                  where: code: req.params.code
                .done ((point) ->
                    GameController.checkPoint user, current_game, point, (game_point) ->
                        console.log "end of api call"
                        res.json
                            user: user
                            game: current_game
                            point: game_point
                )

# METHODS
# -------

formatPoint = (point) ->
    result = point
    return result

selectUserFromReq = (id, req, callback) ->
    User.findOne
        where: id: id
        include: req.getAssocSections ['team']
    .done callback
