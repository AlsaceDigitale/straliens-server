# modules
Sequelize = require 'sequelize'
db = require './db'


# def model
User = db.orm.define 'User',
    id: { type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true }
    pseudo: Sequelize.STRING 25


#export
module.exports = User