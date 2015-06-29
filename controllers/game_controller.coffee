# modules
Sequelize = require 'sequelize'
logger = require '../services/logger'
gameManager = require './game_manager'
# models
Game = require '../models/game'
User = require '../models/user'
Point = require '../models/point'
GamePoint = require '../models/game_point'
GameTeam = require '../models/game_team'
GameUser = require '../models/game_user'
# config
constants = require '../config/constants'


class GameController
    manageEnergy: =>
        logger.info 'controller: Managing energy'
        userEnergyUpd = "LEAST(#{constants.energy.maxValue}, energy + #{constants.energy.value})"
        @currentGame (currentGame) =>
            User.find({}).done (user) =>
                @getGameUser currentGame, user.dataValues, (gameUser) ->
                    GameUser.update energy: Sequelize.literal(userEnergyUpd),
                        where: id: gameUser.id

    currentGame: (callback) ->
        now = new Date
        Game.findOne
            startTime: $lt: now
            endTime: $gt: now
        .done callback

    getGameUser: (game, user, cb) ->
        GameUser.findOrCreate
            defaults: score: 0
            where:
                userId: user.id
                gameId: game.id
        .done (gameUser) ->
            cb gameUser[0]

    getGameTeamForTeam: (game, team, cb) ->
        GameTeam.findOrCreate
            where:
                teamId: team.id
                gameId: game.id
        .done (gameTeam) ->
            cb gameTeam[0]

    getGameTeamForUser: (game, user, cb) ->
        GameTeam.findOrCreate
            where:
                teamId: user.teamId
                gameId: game.id
        .done (gameTeam) ->
            cb gameTeam[0]

    checkPoint: (user, game, point, cb) ->
        logger.info "controller: Point check gid=#{game.id} pid=#{point.id} uid=#{user.id}"
        GamePoint.findOrCreate
            defaults: energy: 0
            where:
                pointId: point.id
                gameId: game.id
        .done (gamePoint) =>
            GameController.getGameUser game, user, (gameUser) ->
                pointEnergyUpd = "energy + #{gameUser.energy}"
                GameUser.update energy: 0,
                    where: id: gameUser.id
                GamePoint.update energy: Sequelize.literal(pointEnergyUpd),
                    where: id: gamePoint[0].dataValues.id
                .done =>
                    GamePoint.find id: gamePoint.id
                    .done (gamePoint) =>
                        @getGameTeamForUser game, user, (gameTeam) ->
                            gameManager.onPointCheckin game, gameUser, gameTeam, (gameUser, gameTeam) ->
                                cb gameUser, gameTeam, gamePoint

# export
module.exports = new GameController
