# modules
Sequelize = require 'sequelize'
db = require './db'
User = require './user'
Game = require './game'

# def model
GameUser = db.orm.define 'GameUser',
    score: Sequelize.INTEGER

# def model assocs
GameUser.belongsTo User,
    foreignKey: 'userId'
    as: 'user'

GameUser.belongsTo Game,
    foreignKey: 'gameId'
    as: 'game'


#export
module.exports = GameUser