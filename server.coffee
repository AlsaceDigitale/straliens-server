global._ = require 'lodash'
# modules
express = require 'express'
nodeHttp = require 'http'
colors = require 'colors'
console = require 'better-console'
db = require './models/db'
ws = require './websockets/websockets'
http = require './services/http'
logger = require './services/logger'
gameController = require './controllers/game_controller'
# config
net = require './config/networking'
constants = require './config/constants'


# DATABASE
# --------
do db.syncSchemas

# EXPRESS / SOCKET.IO
# -------------------
app = express()
httpServer = nodeHttp.Server app
# socket.io
ws.setHttpServer httpServer
# add middlewares
http.addSession app, ws.io
http.addThirdPartyMiddlewares app
http.tuneResponses app
# def routing
api = require './api'
api app
# def static
app.use express.static "#{__dirname}/static/web/build"


# START APPLICATION
# -----------------
# start http + websockets
httpServer.listen net.http.port, ->
    logger.info "HTTP/WS listening on *:#{net.http.port}".green

# start game logic
setInterval gameController.manageEnergyUser, constants.energy.user.frequencyMs
setInterval gameController.manageEnergyPoint, constants.energy.point.frequencyMs
setInterval gameController.assignTeams, 30000

# log errors
process.on 'uncaughtException', (err) ->
    console.error err.stack
