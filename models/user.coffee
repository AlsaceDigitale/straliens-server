# modules
Sequelize = require 'sequelize'
db = require './db'
Team = require './team'


# custom validation constraints
checkUnique = (value, next) ->
    User.find where: nickname: value
        .then (user) ->
            if user then return next 'This username already exists!'
            return next()
        .catch (err) ->
            return next err
checkNotNull = (value, next) ->
    if value.length == 0
        throw new Error('Atention valeur nulle')
    else
        next()

notNull:
    msg: "Valeur nulle"


# def model
User = db.orm.define 'User',
    id:
        type: Sequelize.INTEGER
        primaryKey: true
        autoIncrement: true
    nickname:
        type: Sequelize.STRING 25
        unique: true
        allowNull: false
        validate:
            len: [3, 25]
            isUnique: checkUnique
            isNotNull: checkNotNull
    email:
        type: Sequelize.STRING 25
        unique: true
        allowNull: false
        validate:
            len: [3, 25]
            isUnique: checkUnique
            isNotNull: checkNotNull
    password:
        type: Sequelize.STRING
        allowNull: false
        validate:
            isNotNull: checkNotNull
            len: [6,100]


# def model assocs
User.belongsTo Team,
    foreignKey: 'teamId'
    as: 'team'

#export
module.exports = User