ws = require './websockets'

class ChatManager
    # chat handling
    ws.on 'connection.authenticated', (socket) =>
        # client tries to post something to global chat
        socket.on 'postGlobalChat', (data) =>
            return unless validateFormat data
            date = new Date
            ws.sendToUserTeam socket.user, 'globalChat',
                type: 'msg'
                sender: socket.user
                time: date
                content: 'A nice global message'

        # client tries to post something to teams chat
        socket.on 'postTeamChat', (data)=>
            return unless validateFormat data
            date = new Date
            ws.sendToUserTeam socket.user, 'teamChat',
                type: 'msg'
                sender: socket.user
                time: date
                content: 'A nice team message'

    # check if the content is right
    # todo
    validateFormat = (content) ->
        #if not content.type or not content.date or not content.content
        #    return false
        return true
    # check message for "bad" words
    # todo
    politicalRectifier = (message) ->
        return message

# export
module.exports = new ChatManager
