# modules
socketIo = require 'socket.io'

class WebSockets
    # socket.io object
    io: null
    clients: {}

    setHttpServer: (httpServer) ->
        @io = socketIo httpServer
        do @handleConnection

    handleConnection: ->
        @io.on 'connection', (socket) =>
            socket.user = socket.handshake.session.user
            # if the client isn't authenticated, close the connection
            unless socket.user
                socket.conn.close()
                return
            # register the client
            @clients[socket.user.id] = [] if not @clients[socket.user.id]
            socket.emit 'message', 'test'


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
