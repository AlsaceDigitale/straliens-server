# modules
Sequelize = require 'sequelize'
db = require './db'

# def model
Game = db.orm.define 'Game',
    id:
        type: Sequelize.INTEGER
        primaryKey: true
        autoIncrement: true
    startTime: Sequelize.DATE
    endTime: Sequelize.DATE

#export
module.exports = Game