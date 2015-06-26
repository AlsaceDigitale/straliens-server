# modules
Sequelize = require 'sequelize'
logger = require '../services/logger'
# config
net = require '../config/networking'


# connect to the database
orm = new Sequelize net.sql.database, net.sql.username, net.sql.password, logging: false


# syncs the shemas to the db
syncSchemas = (callback) ->
    require './user'
    require './game'
    require './team'
    require './point'
    require './game_user'
    require './game_point'
    require './game_team'

    orm.sync()
        .then ->
            logger.info 'Database synced with schemas.'
            do callback if callback


# export
module.exports =
    orm: orm
    syncSchemas: syncSchemas