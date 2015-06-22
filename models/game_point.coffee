# modules
Sequelize = require 'sequelize'
db = require './db'
Point = require './point'
Game = require './game'

# def model
GamePoint = db.orm.define 'GamePoint',
    energy: Sequelize.INTEGER
    type: Sequelize.STRING 10

# def model assocs
GamePoint.belongsTo Point,
    foreignKey: 'pointId'
    as: 'point'

GamePoint.belongsTo Game,
    foreignKey: 'gameId'
    as: 'game'


#export
module.exports = GamePoint