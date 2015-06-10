# modules
Sequelize = require 'sequelize'
db = require './db'


# def model
User = db.orm.define 'User',
    id:
        type: Sequelize.INTEGER
        primaryKey: true
        autoIncrement: true
    nickname:
        type: Sequelize.STRING 25
        allowNull: false


#export
module.exports = User