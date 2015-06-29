# modules
Sequelize = require 'sequelize'
db = require './db'

# custom validation constraints
checkUnique = (value, next) ->
    User.find where: nickname: value
        .then (user) ->
            if user then return next 'This name already exists'
            return next()
        .catch (err) ->
            return next err
            
checkNotNull = (value, next) ->
    if value.length == 0
        throw new Error('Atention valeur nulle')
    else
        next()

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