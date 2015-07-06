# modules
Sequelize = require 'sequelize'
db = require './db'

# def model
Point = db.orm.define 'Point',
    id:
        type: Sequelize.INTEGER
        primaryKey: true
        autoIncrement: true
    name: Sequelize.STRING
    address: Sequelize.STRING
    latitude: Sequelize.FLOAT
    longitude: Sequelize.FLOAT
    code: Sequelize.STRING 8

#export
module.exports = Point