# modules
Sequelize = require 'sequelize'
db = require './db'

# custom validation constraints
checkUnique = (value, next) ->
    Team.find where: name: value
        .then (team) ->
            if team then return next 'This team name already exists'
            return next()
        .catch (err) ->
            return next err

checkNotNull = (value, next) ->
    if value.length == 0
        throw new Error 'Cette valeur ne peut être nulle'
    else do next

# def model
Team = db.orm.define 'Team',
    id:
        type: Sequelize.INTEGER
        primaryKey: true
        autoIncrement: true
    name:
        type: Sequelize.STRING 100
        unique: true
        allowNull: false
        validate:
            len: [3, 25]
            isUnique: checkUnique
            isNotNull: checkNotNull
    slogan:
        type: Sequelize.STRING 100
    password:
        type: Sequelize.STRING
        allowNull: false
        validate:
            isNotNull: checkNotNull

Team.sides =
    STRALIENS: "STRALIENS"
    EARTHLINGS: "EARTHLINGS"

#export
module.exports = Team
