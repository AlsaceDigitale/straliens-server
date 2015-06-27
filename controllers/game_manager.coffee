# modules
Sequelize = require 'sequelize'
# models
Game = require '../models/game'
Point = require '../models/point'
GamePoint = require '../models/game_point'
GameUser = require '../models/game_user'
GameTeam = require '../models/game_team'
# config
constants = require '../config/constants'


GameManager =

    onPointCheckin: (game, gameUser, gameTeam, cb) ->
        console.log "GameManager.onPointCheckin #{game_user} #{gameTeam}"
        GameUser.update score: Sequelize.literal("score + #{constants.score.checkPoint.user}"),
            where:
                userId: gameUser.id
                gameId: game.id
        .done ->
            GameTeam.update score: Sequelize.literal("score + #{constants.score.checkPoint.team}"),
                where:
                    teamId: gameTeam.id
                    gameId: game.id
            .done ->
                GameUser.find
                    userId: gameUser.id
                    gameId: game.id
                .done (gameUser) ->
                    GameTeam.find
                        teamId: gameTeam.id
                        gameId: game.id
                    .done (gameTeam) ->
                        cb gameUser, gameTeam


#export
module.exports = GameManager
