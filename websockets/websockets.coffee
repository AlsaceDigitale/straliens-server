# modules
socketIo = require 'socket.io'


class WebSockets
    # socket.io object
    io: null

    setHttpServer: (httpServer) ->
        @io = socketIo httpServer
        do @handleConnection

    handleConnection: ->
        @io.on 'connection', (socket) ->
            socket.user = socket.handshake.session.user


# export
module.exports = new WebSockets
