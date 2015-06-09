# modules
app = do require 'express'

# config
networking = require './config/networking'


# EXPRESS BOOTSTRAP
# -----------------
api = require './api'
app.use '/api', api

app.listen networking.http.port


# SOCKET.IO BOOTSTRAP
# -------------------

# todo ;p