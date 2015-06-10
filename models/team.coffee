# modules
Sequelize = require 'sequelize'
db = require './db'


# def model
Team = db.orm.define 'Team',
    id:
        type: Sequelize.INTEGER
        primaryKey: true
        autoIncrement: true
    tag:
        type: Sequelize.STRING 10
        allowNull: false
    slogan: Sequelize.STRING 100


#export
module.exports = Team