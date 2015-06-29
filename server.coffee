# modules
express = require 'express'
nodeHttp = require 'http'
socketIo = require 'socket.io'
colors = require 'colors'
db = require './models/db'
http = require './services/http'
logger = require './services/logger'
gameController = require './controllers/game_controller'
# config
net = require './config/networking'
constants = require './config/constants'


# DATABASE
# --------
do db.syncSchemas


# EXPRESS HTTP
# ------------
app = express()
# add middlewares
http.addThirdPartyMiddlewares app
http.tuneResponses app
# def routing
api = require './api'
api app
# listen
httpServer = nodeHttp.Server app


# SOCKET.IO WEBSOCKETS
# --------------------
io = socketIo httpServer
io.on 'connection', (socket) ->
    # console.log 'an user is now using websockets'
    # socket.on 'msg', (msg...


# EXPOSE LANDING FILES
# --------------------
app.use express.static "#{__dirname}/index"
app.get '/', (req, res) ->
    res.sendFile '/index.html'


# START APPLICATION
# -----------------
# start http + websockets
httpServer.listen net.http.port, ->
    logger.info "HTTP/WS listening on *:#{net.http.port}".green

# start game logic
setInterval gameController.manageEnergy, constants.energy.frequencyMs
setInterval gameController.assignTeams, 30000
