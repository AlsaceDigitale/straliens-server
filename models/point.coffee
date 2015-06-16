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
    lat: Sequelize.FLOAT
    lng: Sequelize.FLOAT

#export
module.exports = Point