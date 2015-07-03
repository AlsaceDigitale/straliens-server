# modules
ws = require './websockets'
User = require '../models/user'


notify = (receiver, message, options = {}) ->
    # detecting the type of the receiver
    if receiver.dataValues.hasOwnProperty 'nickname'
        method = if options.teamify then ws.sendToUserTeam else ws.sendToUser
    else if receiver.dataValues.hasOwnProperty 'slogan'
        method = ws.sendToTeam
    else throw new Error 'Notify function only takes user or team objects in the receiver argument'
    # send the notification
    method receiver, 'notification:post', message, options


# export
module.exports = notify
