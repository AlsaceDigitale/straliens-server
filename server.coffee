# modules
app = do require 'express'
db = require './models/db'
http = require './services/http'
# config
net = require './config/networking'


# DATABASE
# --------
do db.syncSchemas


# EXPRESS BOOTSTRAP
# -----------------
# add middlewares
http.addThirdPartyMiddlewares app
http.tuneResponses app
# def routing
api = require './api'
app.use '/api', api
# listen
app.listen net.http.port


# SOCKET.IO BOOTSTRAP
# -------------------

# todo ;p