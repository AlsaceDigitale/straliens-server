ws = require './websockets'

class ChatManager
    # chat handling
    ws.on 'connection.authenticated', (socket) =>
        # client tries to post something to global chat
        socket.on 'chat:global:post', (data) =>
            return unless validateFormat data
            date = new Date
            ws.sendToUserTeam socket.user, 'chat:global:in',
                type: 'msg'
                sender: socket.user
                time: date
                content: data.content

        # client tries to post something to teams chat
        socket.on 'chat:team:post', (data) =>
            return unless validateFormat data
            date = new Date
            ws.sendToUserTeam socket.user, 'chat:team:in',
                type: 'msg'
                sender: socket.user
                time: date
                content: data.content

        # client tries to post something to their side chat
        # TODO not implemented
        socket.on 'chat:side:post', (data) =>
            return
#           return unless validateFormat data
#           date = new Date
#           ws.sendToUserTeam socket.user, 'chat:side:in',
#               type: 'msg'
#               sender: socket.user
#               time: date
#               content: data.content

        # client tries to post something to the support chat
        # TODO not implemented
        socket.on 'chat:support:post', (data) =>
            return
#           return unless validateFormat data
#           date = new Date
#           ws.sendToUserTeam socket.user, 'chat:support:in',
#               sender: socket.user
#               time: date
#               content: data.content
    # check if the content is right
    validateFormat = (content) ->
        if not content.type or not content.content then return false
        if content.type != 'msg' then return false
        return true
    # check message for "bad" words, and replaces them
    # TODO not implemented
    politicalRectifier = (message) ->
        return message

# export
module.exports = new ChatManager
