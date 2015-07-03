# modules
express = require 'express'
nodeHttp = require 'http'

port = process.env.PORT || 8000

# EXPRESS / SOCKET.IO
# -------------------
app = express()
httpServer = nodeHttp.Server app

# EXPOSE STATIC WEBSITE
# --------------------
app.use express.static "#{__dirname}/web/build"

# START APPLICATION
# -----------------
# start http
httpServer.listen port, ->
    console.log "HTTP listening on *:#{port}"