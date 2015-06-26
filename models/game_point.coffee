# modules
Sequelize = require 'sequelize'
db = require './db'
Point = require './point'
Game = require './game'

# def model
GamePoint = db.orm.define 'GamePoint',
    energy: Sequelize.INTEGER
    type: Sequelize.STRING 10
    side:
        type: Sequelize.VIRTUAL
        get: ->
            return 'NEUTRAL' if this.energy is 0
            return 'EARTHLINGS' if this.energy < 0
            'STRALIENS'

# def model assocs
GamePoint.belongsTo Point,
    foreignKey: 'pointId'
    as: 'point'

GamePoint.belongsTo Game,
    foreignKey: 'gameId'
    as: 'game'


#export
module.exports = GamePoint