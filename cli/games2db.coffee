# modules
colors = require 'colors'
logger = require '../services/logger'
db = require '../models/db'

Game = require '../models/game'
GamePoint = require '../models/game_point'
# points data
gameDatas = require '../resources/games.json'
pointDatas = require '../resources/points.json'

# BEGIN
# ------
createGameFn = (id, startTime, endTime) ->
    Game.create
        id: id
        startTime: startTime
        endTime: endTime

createGamePointFn = (gameId, pointId, type) ->
    GamePoint.create
        type: ""
        energy: 0
        gameId: gameId
        pointId: pointId
        type: type

db.orm.query('SET FOREIGN_KEY_CHECKS = 0', {raw: true}).then -> Game.drop().then -> db.syncSchemas ->
    for game in gameDatas.games
        createGameFn game.id, game.startTime, game.endTime
        logger.info "importing game \"#{game.startTime}\" -> \"#{game.endTime}\"".underline
        logger.info "creating pointGame"
        for point in pointDatas.points
            if point.type == null
                type = ""
            else
                type = point.type
            createGamePointFn game.id, point.id, type
        