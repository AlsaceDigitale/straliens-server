# modules
Sequelize = require 'sequelize'
logger = require '../services/logger'
gameManager = require './game_manager'
# models
Game = require '../models/game'
Team = require '../models/team'
User = require '../models/user'
Point = require '../models/point'
GamePoint = require '../models/game_point'
GameTeam = require '../models/game_team'
GameUser = require '../models/game_user'
# config
constants = require '../config/constants'
db = require '../models/db'

class GameController

    getTeamsCount: (callback) =>
        sql="""
        select count(*)-1 as count, side from (
        select count(*), side from GameTeams group by side
        UNION
        select * from (SELECT 0 as 'count(*)', "STRALIENS" as 'side' UNION
        SELECT 0 as 'count(*)', "EARTHLINGS" as 'side' ) sides ) x group by side;
        """
        db.orm.query sql, type: Sequelize.QueryTypes.SELECT
        .then (data) ->
            ret =
                EARTHLINGS: 0
                STRALIENS: 0

            for k of data
                d=data[k]
                if d.side == Team.sides.EARTHLINGS
                    ret.EARTHLINGS = d.count
                else
                    ret.STRALIENS = d.count

            if callback
                callback ret


    manageEnergyUser: =>
        logger.info 'controller: Managing energy for users'
        userEnergyUpd = "LEAST(#{constants.energy.user.maxValue}, energy + #{constants.energy.user.value})"
        @currentGame (currentGame) =>
            User.findAll()
            .done (users) =>
                if !users or !currentGame then return
                for user in users
                    @getGameUser currentGame, user.dataValues, (gameUser) ->
                        GameUser.update energy: Sequelize.literal(userEnergyUpd),
                            where: id: gameUser.id
                        .done ->
                            GameUser.findOne
                                where: id: gameUser.id
                            .done (gameUser) ->
                                gameManager.onGameUserChange gameUser

    manageEnergyPoint: =>
        logger.info 'controller: Managing energy for points'
        pointEnergyUpd = "GREATEST(0,LEAST(#{constants.energy.point.maxValue}, energy - #{constants.energy.point.valueDecay}))"
        @currentGame (currentGame) =>
            Point.findAll({}).done (points) =>
                if !points or !currentGame then return
                for point in points
                    @getGamePoint point.dataValues, currentGame, (gamePoint) =>
                        console.log "gamePoint #{gamePoint.id}"
                        GamePoint.update energy: Sequelize.literal(pointEnergyUpd),
                            where: id: gamePoint.id
                        .done ->
                            GamePoint.findOne
                                where: id: gamePoint.id
                            .done (gamePoint) ->
                                gameManager.onGamePointChange gamePoint


    assignTeams: =>
        logger.info 'controller: Assign teams'
        @currentGame (currentGame) =>
            if !currentGame then return
            Team.find({}).done (team) =>
                @getGameTeamForTeam currentGame, team, (gameTeam) =>
                    @getTeamsCount (teamsCount) =>
                        if [Team.sides.EARTHLINGS, Team.sides.STRALIENS].indexOf(gameTeam.dataValues.side) < 0
                            nextTeam = if teamsCount.STRALIENS > teamsCount.EARTHLINGS then Team.sides.EARTHLINGS else Team.sides.STRALIENS
                            console.log "Assigning side #{nextTeam} to GameTeam #{gameTeam.dataValues.id}"
                            GameTeam.update side: nextTeam,
                                where: id: gameTeam.dataValues.id

    currentGame: (callback) ->
        now = new Date
        Game.findOne
            where:
                startTime: $lt: now
                endTime: $gt: now
        .done callback

    getGamePoint: (point, game, callback) ->
        GamePoint.findOrCreate
            defaults: energy: 0
            where:
                pointId: point.id
                gameId: game.id
            defaults:
                energy: 0
        .done (gamePoint) ->
            callback gamePoint[0]

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

    checkPoint: (user, game, point, lat, lng, useGPS, cb) ->
        logger.info "controller: Point check gid=#{game.id} pid=#{point.id} uid=#{user.id}"
        @getGamePoint point, game, (gamePoint) =>
            @getGameUser game, user, (gameUser) =>
                # Check if coordinates are right
                if useGPS
                    if @checkCoordinates(lat, lng, point.dataValues.lat, point.dataValues.lng, 200) == false
                        console.log "Rejecting checkin of point #{point.id} with coords #{lat} #{lng} by user #{user.id}"
                        return
                @getGameTeamForUser game, user, (gameTeam) ->
                    GameUser.update
                        energy: 0
                    ,
                        where:
                            id: gameUser.id
                    logger.info "Current user team side is #{gameTeam.side}"
                    expr=if gameTeam.side == Team.sides.STRALIENS then "energy + #{gameUser.energy}" else "energy - #{gameUser.energy}"
                    GamePoint.update
                        energy: Sequelize.literal(expr)
                    ,
                        where:
                            id: gamePoint.id
                    .done =>
                        GamePoint.find
                            where:
                                id: gamePoint.id
                        .done (gamePoint) ->
                            gameManager.onPointCheckin game, gameUser, gameTeam, gamePoint, (gameUser, gameTeam) ->
                                cb gameUser, gameTeam, gamePoint

    # Checks if coordinates are inside radius of a point
    # uLat, uLng are the coordinates of the moving point
    # tLat, tLng are the coordinates of the fixed target.
    # delta is the radius around the fixed target where we consider we are in range (In meter)
    checkCoordinates: (uLat, uLng, tLat, tLng, delta) ->
        return false unless delta > 0
        earthRadius = 6372.8 # Km
        uLat = uLat/180 * Math.PI
        uLng = uLng/180 * Math.PI
        tLat = tLat/180 * Math.PI
        tLng = tLng/180 * Math.PI
        rLat = (tLat - uLat)
        rLng = (tLng - uLng)
        a = Math.sin(rLat / 2) * Math.sin(rLat / 2) + Math.sin(rLng / 2) * Math.sin(rLng / 2) * Math.cos(uLat) * Math.cos(tLat)
        d = (earthRadius * 2 * Math.asin(Math.sqrt(a))) * 1000 # d is the measured distance with the point, in meter
        console.log "distance is #{d}"
        if d <= delta
            return true
        else
            return false

# export
module.exports = new GameController
