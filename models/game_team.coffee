# modules
Sequelize = require 'sequelize'
db = require './db'
Team = require './team'
Game = require './game'

# def model
GameTeam = db.orm.define 'GameTeam',
    score:
        type: Sequelize.INTEGER
        defaultValue: 0
    side:
        type: Sequelize.STRING
        defaultValue: 'NOT_ASSIGNED'

# def model assocs
GameTeam.belongsTo Team,
    foreignKey: 'teamId'
    as: 'team'

GameTeam.belongsTo Game,
    foreignKey: 'gameId'
    as: 'game'


#export
module.exports = GameTeam