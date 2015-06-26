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

isLongEnough = (value, next) ->
    try
        if val.length < 7
            throw new Error('Please choose a longer password')
        else
            return next()
    catch err
        return next err

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
    email:
        type: Sequelize.STRING 25
        unique: true
        allowNull: false
        validate:
            len: [3, 25]
            isUnique: checkUnique
    password_hash:
        type: Sequelize.STRING
        allowNull: false
    password:
        type: Sequelize.VIRTUAL
        allowNull: false
        set: (val) ->
            @setDataValue 'password', val
            # Remember to set the data value, otherwise it won't be validated
            @setDataValue 'password_hash', passwordHash.generate(val);
        validate: isLongEnough

# def model assocs
User.belongsTo Team,
    foreignKey: 'teamId'
    as: 'team'

#export
module.exports = User