# modules
Sequelize = require 'sequelize'
# config
net = require '../config/networking'


# connect to the database
orm = new Sequelize net.sql.database, net.sql.username, net.sql.password, logging: false


# syncs the shemas to the db
syncSchemas = ->
    require './user'
    require './team'
    orm.sync()
        .then -> console.log 'Database synced with schemas.'


# export
module.exports =
    orm: orm
    syncSchemas: syncSchemas