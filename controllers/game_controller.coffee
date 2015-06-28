# modules
Sequelize = require 'sequelize'
# models
Game = require '../models/game'
User = require '../models/user'
Point = require '../models/point'
GamePoint = require '../models/game_point'
GameTeam = require '../models/game_team'
GameUser = require '../models/game_user'

GameManager = require './game_manager'

constants = require '../config/constants'

GameController = {
    manageEnergy: ->
        console.log "Managing energy"
        GameController.currentGame (current_game) ->
            User.find({}).done (user) ->
                GameController.getGameUser current_game, user.dataValues, (game_user) ->
                    GameUser.update
                        energy: Sequelize.literal("LEAST(#{constants.energy.maxValue}, energy + #{constants.energy.value})")
                    ,
                        where:
                            id: game_user.id

    currentGame: (callback) ->
        now = new Date()
        Game.findOne
            startTime:
                $lt: now
            endTime:
                $gt: now
        .done callback

    getGameUser: (game, user, cb) ->
        GameUser.findOrCreate
            defaults:
                score: 0
            where:
                userId: user.id
                gameId: game.id
        .done (game_user) ->
            cb game_user[0]

    getGameTeamForTeam: (game, team, cb) ->
        GameTeam.findOrCreate
            where:
                teamId: team.id
                gameId: game.id
        .done (game_team) ->
            cb game_team[0]

    getGameTeamForUser: (game, user, cb) ->
        GameTeam.findOrCreate
            where:
                teamId: user.teamId
                gameId: game.id
        .done (game_team) ->
            cb game_team[0]

    checkPoint: ((user, game, point, cb) ->
        console.log "checkPoint #{game.id} #{point.id} #{user.id}"
        GamePoint.findOrCreate
            where:
                pointId: point.id
                gameId: game.id
            defaults:
                energy: 0
        .done (game_point) ->
            GameController.getGameUser game, user, (game_user) ->
                GameUser.update
                    energy: 0
                ,
                    where:
                        id: game_user.id
                GamePoint.update
                    energy: Sequelize.literal("energy + #{game_user.energy}")
                ,
                    where:
                        id: game_point[0].dataValues.id
                .done =>
                    GamePoint.find
                        id: game_point.id
                    .done (game_point) ->
                        GameController.getGameTeamForUser game, user, (game_team) ->
                            GameManager.onPointCheckin game, game_user, game_team, (game_user, game_team) ->
                                cb game_user, game_team, game_point
    )
}

module.exports = GameController
