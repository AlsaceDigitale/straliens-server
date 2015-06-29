# modules
socketIo = require 'socket.io'

class WebSockets
    # socket.io object
    io: null
    clients: []

    setHttpServer: (httpServer) ->
        @io = socketIo httpServer
        do @handleConnection

    handleConnection: ->
        @io.on 'connection', (socket) ->
            socket.user = socket.handshake.session.user
            clients.push socket

            socket.on '', ->
                console.log "test" 


# export
module.exports = new WebSockets