# modules
Sequelize = require 'sequelize'
# config
net = require '../config/networking'


# connect to the database
orm = new Sequelize net.sql.database, net.sql.username, net.sql.password

syncSchemas = ->
    require './user'
    orm.sync logging: false
        .then -> console.log 'Database synced with schemas.'


# export
module.exports =
    orm: orm
    syncSchemas: syncSchemas