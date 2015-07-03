# modules
Game = require '../models/game'

gameController = require '../controllers/game_controller'

# CONTROLLER
# ----------
module.exports = (app) ->

    # GET /api/games
    app.get '/api/games/', 'games.list', (req, res) ->
        list = []
        Game.findAll().then (games) ->
            list.push formatGame(game) for game in games
            res.json list

    # GET /api/games/current
    app.get '/api/games/current', 'games.current', (req, res) ->
        gameController.currentGame (currentGame) ->
            if currentGame
                res.json formatGame(currentGame)
            else res.notFoundError()

    # GET /api/games/:id
    app.get '/api/games/:id', 'games.get', (req, res) ->
        res.findOrFail Game, req.params.id, (game) ->
            res.json formatGame(game)


# METHODS
# -------

formatGame = (game) ->
    result = game
    return result
