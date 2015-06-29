bcrypt = require 'bcrypt'
User = require '../models/user'


# CONTROLLER
# ----------
module.exports = (app) ->

    # POST /api/services/login
    app.post '/api/services/login', 'services.login.post', (req, res) ->
        {nickname, password} = req.body
        # check the password
        if not nickname? or not password?
            res.genericError 'Missing parameters', 'AuthenticationError'
        else
            User.findOne
                where: $or:
                    nickname: nickname
                    email: nickname
            .done (user) ->
                unless user
                    res.genericError "User #{nickname} does not exists", 'AuthenticationError'
                else
                    bcrypt.compare password, user.password, (err, same) ->
                        unless same
                            res.genericError "Invalid password for user #{nickname}", 'AuthenticationError'
                        else
                            req.session.user = user.dataValues
                            res.json formatUser(user)

formatUser = (user) ->
    result = user
    delete result.dataValues.password
    return result
