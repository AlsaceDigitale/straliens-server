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

            console.log "new client"

            socket.on '', ->
                console.log "test"


# export
module.exports = new WebSockets

# Message : {
#   type: "message|notif"
#   to: "public|team|side",
#    msg: "content of message",
#    author: {
#        id: "ID",
#        user: "Username"
#    },
#    cDate: "Datetime",
#}