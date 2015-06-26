# modules
Sequelize = require 'sequelize'
db = require './db'
Team = require './team'


# custom validation constraints
checkUnique = (value, next) ->
    User.find
        where: $or:
                nickname: value
                email: value
    .then (user) ->
        if user then return next 'Ce nom d\'utilisateur ou cet e-mail ont déjà été choisis.'
        return next()
    .catch (err) ->
        return next err

checkNotNull = (value, next) ->
    if value.length == 0
        throw new Error 'Valeur nulle non autorisée'
    else
        next()

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

# def model assocs
User.belongsTo Team,
    foreignKey: 'teamId'
    as: 'team'

#export
module.exports = User
