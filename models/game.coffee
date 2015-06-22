# modules
Sequelize = require 'sequelize'
db = require './db'

# def model
Game = db.orm.define 'Game',
    id:
        type: Sequelize.INTEGER
        primaryKey: true
        autoIncrement: true
    start_time: Sequelize.DATE
    end_time: Sequelize.DATE

#export
module.exports = Game