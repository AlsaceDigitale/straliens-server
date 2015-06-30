# modules
Game = require '../models/game'


# CONTROLLER
# ----------
module.exports = (app) ->

    # GET /api/games
    app.get '/api/games/', 'games.list', (req, res) ->
        list = []
        Game.findAll().then (games) ->
            list.push formatGame(game) for game in games
            res.json list

    # GET /api/games/:id
    app.get '/api/games/:id', 'games.get', (req, res) ->
        res.findOrFail Game, req.params.id, (game) ->
            res.json formatGame(game)


# METHODS
# -------

formatGame = (game) ->
    result = game
    return result
