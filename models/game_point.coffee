# modules
Sequelize = require 'sequelize'
db = require './db'
Point = require './point'
Game = require './game'

constants = require '../config/constants'

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
    absEnergy:
        type: Sequelize.VIRTUAL
        get: ->
            return Math.abs(this.energy)

    remainingTimeSeconds:
        type: Sequelize.VIRTUAL
        get: ->
            return this.absEnergy * constants.energy.point.frequencyMs / 1000 / constants.energy.point.valueDecay

# def model assocs
GamePoint.belongsTo Point,
    foreignKey: 'pointId'
    as: 'point'

GamePoint.belongsTo Game,
    foreignKey: 'gameId'
    as: 'game'


#export
module.exports = GamePoint