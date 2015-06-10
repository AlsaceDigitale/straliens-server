# modules
app = do require 'express'
db = require './models/db'
# config
net = require './config/networking'


# DATABASE
# --------
do db.syncSchemas


# EXPRESS BOOTSTRAP
# -----------------
api = require './api'
app.use '/api', api

app.listen net.http.port


# SOCKET.IO BOOTSTRAP
# -------------------

# todo ;p