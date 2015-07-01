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
            res.genericError 'Paramètres invalides', 'AuthenticationError'
        else
            User.findOne
                where: $or:
                    nickname: nickname
                    email: nickname
            .done (user) ->
                unless user
                    res.genericError "Utilisateur #{nickname} n'existe pas", 'AuthenticationError'
                else
                    bcrypt.compare password, user.password, (err, same) ->
                        unless same
                            res.genericError "Mot de passe invalide pour #{nickname}", 'AuthenticationError'
                        else
                            req.session.user = user.dataValues
                            selectUserFromReq user.id, req, (user) ->
                                res.json formatUser(user)

    # GET /api/services/logged-in
    app.get '/api/services/logged-in', 'services.logged-in.get', (req, res) ->
        res.json req.session.user?


formatUser = (user) ->
    result = user
    delete result.dataValues.password
    return result

selectUserFromReq = (id, req, callback) ->
    User.findOne
        where: id: id
        include: req.getAssocSections ['team']
    .done callback
