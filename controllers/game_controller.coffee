Sequelize = require 'sequelize'

Game = require '../models/game'
Point = require '../models/point'
GamePoint = require '../models/game_point'
GameTeam = require  '../models/game_team'
GameUser = require '../models/game_user'
GameManager = require  './game_manager'

GameController = {
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
      GamePoint.update
        energy: Sequelize.literal('energy + 1')
      ,
        where:
          id: game_point[0].dataValues.id
      .done =>
        GamePoint.find
          id: game_point.id
        .done (game_point) ->
          GameController.getGameUser game, user, (game_user) ->
            GameController.getGameTeamForUser game, user, (game_team) ->
              GameManager.onPointCheckin game, game_user, game_team, (game_user, game_team) ->
                cb game_user, game_team, game_point
  )
}

module.exports = GameController