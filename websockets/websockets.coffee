# modules
socketIo = require 'socket.io'
events = require 'events'
logger = require '../services/logger'

class WebSockets extends events.EventEmitter
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
            @emit 'connection', socket
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
            @emit 'connection.authenticated', socket
            socket.on 'disconnect', =>
                delete @users[socket.user.id][socket.id]
                delete @teams[socket.user.teamId][socket.id]

    # sends a message to ALL, even the
    # not authenticated connections.
    broadcast: (action, datas...) =>
        @io.emit action, datas...

    # sends a message to an user.
    # 'user' argument is a Sequelize user.
    # if you only have the id, call it in this way:
    # sendToUser id: myId, action, data
    sendToUser: (user, action, datas...) =>
        logger.info "websockets: sendToUser #{user.id}"
        for id, socket of @users[user.id]
            socket.emit action, datas...

    # send a message to a team, using an user
    # 'user' argument is a Sequelize user
    sendToUserTeam: (user, action, datas...) =>
        unless user.teamId then return
        for id, socket of @teams[user.teamId]
            socket.emit action, datas...

    # send a message to a team
    # 'team' argument is a Sequelize team
    sendToTeam: (team, action, datas...) =>
        for id, socket of @teams[team.id]
            socket.emit action, datas...

    # send a message to all users, except the sender
    sendToUsers: (sender, action, datas...) =>
        for user of @users
            if parseInt(user) != parseInt(sender.id)
                for id, socket of @users[user]
                    socket.emit action, datas...


# export
module.exports = new WebSockets
