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


# EXPOSE LANDING FILES
# --------------------
app.use express.static "#{__dirname}/index"
app.get '/', (req, res) -> res.sendFile '/index.html'


# START APPLICATION
# -----------------
# start http + websockets
httpServer.listen net.http.port, ->
    logger.info "HTTP/WS listening on *:#{net.http.port}".green

# start game logic
setInterval gameController.manageEnergy, constants.energy.frequencyMs
setInterval gameController.assignTeams, 30000

process.on 'uncaughtException', (err) -> 
    console.error err