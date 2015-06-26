Sequelize = require 'sequelize'

Game = require '../models/game'
Point = require '../models/point'
GamePoint = require '../models/game_point'

GameController = {
  currentGame: (callback) ->
    now = new Date()
    Game.findOne
      startTime:
        $lt: now
      endTime:
        $gt: now
    .done callback

  checkPoint: ((user, game, point, cb) ->
    console.log "checkPoint #{game.id} #{point.id}"
    GamePoint.findOrCreate
      where:
        pointId: point.id
        gameId: game.id
      defaults:
        energy: 0
    .done (game_point) ->
      console.log game_point
      GamePoint.update
        energy: Sequelize.literal('energy + 1')
      ,
        where:
          id: game_point[0].dataValues.id
      .done =>
        GamePoint.find
          id: game_point.id
        .done (game_point) ->
          cb game_point
  )
}

module.exports = GameController