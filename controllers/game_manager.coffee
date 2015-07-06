# modules
Sequelize = require 'sequelize'
ws = require '../websockets/websockets'

# models
Game = require '../models/game'
Point = require '../models/point'
GamePoint = require '../models/game_point'
GameUser = require '../models/game_user'
GameTeam = require '../models/game_team'
# config
constants = require '../config/constants'


class GameManager
    onPointCheckin: (game, gameUser, gameTeam, gamePoint, cb) ->
        console.log "manager: Point checkin gameUser #{gameUser.id} gameTeam #{gameTeam.id}"
        userScoreUpd = "score + #{constants.score.checkPoint.user}"
        teamScoreUpd = "score + #{constants.score.checkPoint.team}"

        @sendUpdatedPoint gamePoint

        GameUser.update score: Sequelize.literal(userScoreUpd),
            where:
                id: gameUser.id
        .done ->
            GameTeam.update score: Sequelize.literal(teamScoreUpd),
                where:
                    id: gameTeam.id
            .done ->
                GameUser.findOne
                    where:
                        id: gameUser.id
                .done (gameUser) ->
                    GameTeam.findOne
                        where:
                            id: gameTeam.id
                    .done (gameTeam) ->
                        ws.sendToUser id: gameUser.userId, "score:update", gameUser.score, gameTeam.score
                        cb gameUser, gameTeam

    sendUpdatedPoint: (gamePoint) =>
        gamePoint.getPoint()
        .then (point) ->
            ws.broadcast "point:update", gamePoint: gamePoint, point: point

    sendUpdatedGamePoints: (gamePoints) ->
        Promise.all _.map gamePoints, (gamePoint) ->
            gamePoint.getPoint()
            .then (point) ->
                return {point: point, gamePoint: gamePoint}
        .then (data) ->
            ws.broadcast "points:update", data

    onGameUserChange: (gameUser) ->
        ws.sendToUser id: gameUser.userId, "user:update", energy: gameUser.energy


#export
module.exports = new GameManager
