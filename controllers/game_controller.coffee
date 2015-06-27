# modules
Sequelize = require 'sequelize'
# models
Game = require '../models/game'
Point = require '../models/point'
GamePoint = require '../models/game_point'
GameTeam = require '../models/game_team'
GameUser = require '../models/game_user'
GameManager = require './game_manager'


GameController =

    currentGame: (callback) ->
        now = new Date
        Game.findOne
            startTime: $lt: now
            endTime: $gt: now
        .done callback

    getGameUser: (game, user, cb) ->
        GameUser.findOrCreate
            defaults:
                score: 0
            where:
                userId: user.id
                gameId: game.id
        .done (gameUser) ->
            cb gameUser[0]

    getGameTeamForUser: (game, user, cb) ->
        GameTeam.findOrCreate
            where:
                teamId: user.teamId
                gameId: game.id
        .done (gameTeam) ->
            cb gameTeam[0]

    checkPoint: (user, game, point, cb) ->
        console.log "checkPoint Game: #{game.id} Point: #{point.id} User: #{user.id}"
        GamePoint.findOrCreate
            where:
                pointId: point.id
                gameId: game.id
            defaults:
                energy: 0
        .done (gamePoint) ->
            GamePoint.update energy: Sequelize.literal('energy + 1'),
                where:
                    id: gamePoint[0].dataValues.id
            .done =>
                GamePoint.find
                    id: gamePoint.id
                .done (gamePoint) ->
                    GameController.getGameUser game, user, (gameUser) ->
                        GameController.getGameTeamForUser game, user, (gameTeam) ->
                            GameManager.onPointCheckin game, gameUser, gameTeam, (gameUser, gameTeam) ->
                                cb gameUser, gameTeam, gamePoint

# export
module.exports = GameController
