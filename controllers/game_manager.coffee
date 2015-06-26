Sequelize = require 'sequelize'

Game = require '../models/game'
Point = require '../models/point'
GamePoint = require '../models/game_point'
GameUser = require '../models/game_user'
GameTeam = require '../models/game_team'

constants = require '../config/constants'

GameManager = {
  onPointCheckin: (game, game_user, game_team, cb) ->
    console.log "GameManager.onPointCheckin #{game_user} #{game_team}"
    GameUser.update
      score: Sequelize.literal("score + #{constants.score.checkPoint.user}")
    ,
      where:
        userId: game_user.id
        gameId: game.id
    .done ->
      GameTeam.update
        score: Sequelize.literal("score + #{constants.score.checkPoint.team}")
      ,
        where:
          teamId: game_team.id
          gameId: game.id
      .done ->
        GameUser.find
          userId: game_user.id
          gameId: game.id
        .done (game_user) ->
          GameTeam.find
            teamId: game_team.id
            gameId: game.id
          .done (game_team) ->
            cb game_user, game_team
}

module.exports = GameManager