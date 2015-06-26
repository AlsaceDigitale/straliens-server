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
            return 'neutral' if this.energy is 0
            return 'earthlings' if this.energy < 0
            'straliens'

# def model assocs
GamePoint.belongsTo Point,
    foreignKey: 'pointId'
    as: 'point'

GamePoint.belongsTo Game,
    foreignKey: 'gameId'
    as: 'game'


#export
module.exports = GamePoint