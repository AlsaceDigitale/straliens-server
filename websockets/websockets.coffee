# modules
socketIo = require 'socket.io'

class WebSockets
    # socket.io object
    io: null
    users: {}
    teams: {}

    setHttpServer: (httpServer) ->
        @io = socketIo httpServer
        do @handleConnection

    # handles user connections, authenticate them
    # and handles multiple connections by user
    handleConnection: ->
        @io.on 'connection', (socket) =>
            socket.user = socket.handshake.session.user
            # if the client isn't authenticated, do not continue
            unless socket.user then return
            # register the user
            @users[socket.user.id] = {} if not @users[socket.user.id]
            @users[socket.user.id][socket.id] = socket
            # register the team
            if socket.user.teamId
                @teams[socket.user.teamId] = {} if not @teams[socket.user.teamId]
                @teams[socket.user.teamId][socket.id] = socket

            @sendToTeam id: 1, 'message', Object.keys(@users[socket.user.id])

            socket.on 'disconnect', =>
                delete @users[socket.user.id][socket.id]
                delete @teams[socket.user.teamId][socket.id]

    # sends a message to ALL, even the
    # not authenticated connections.
    broadcast: (action, datas...) ->
        @io.emit action, datas...

    # sends a message to an user.
    # 'user' argument is a Sequelize user.
    # if you only have the id, call it in this way:
    # sendToUser id: myId, action, data
    sendToUser: (user, action, datas...) ->
        for id, socket of @users[user.id]
            socket.emit action, datas...

    # send a message to a team, using an user
    # 'user' argument is a Sequelize user
    sendToUserTeam: (user, action, datas...) ->
        unless user.teamId then return
        for id, socket of @teams[user.teamId]
            socket.emit action, datas...

    # send a message to a team
    # 'team' argument is a Sequelize team
    sendToTeam: (team, action, datas...) ->
        for id, socket of @teams[team.id]
            socket.emit action, datas...


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
