# modules
_ = require 'underscore'
_.mixin require 'underscore.deepclone'
bcrypt = require 'bcrypt'
User = require '../models/user'
Team = require '../models/team'


# CONTROLLER
# ----------
module.exports = (app) ->

    # GET /api/users
    app.get '/api/users', 'users.list', (req, res) ->
        list = []
        User.findAll().then (users) ->
            list.push formatUser(user) for user in users
            res.json list


    # GET /api/users/:id
    app.get '/api/users/:id', 'users.get', (req, res) ->
        selectUserFromReq req.params.id, req, (user) ->
            if user then res.json formatUser(user)
            else res.notFoundError()


    # POST /api/users
    app.post '/api/users', 'users.post', (req, res) ->
        # check the password
        if not req.body.password? or req.body.password.length < 5
            res.validationError fields: [
                path: 'password'
                message: 'Le mot de passe doit faire au moins 5 caractères'
            ]
            return
        # check if team size limit is not reached
        if not req.body.teamId or req.body.teamId == null
            res.validationError fields: [
                path: 'teamId'
                message: 'Aucune équipe n\'a été spécifiée'
            ]
            return
        User.count where: teamId: req.body.teamId
        .then (amount) ->
            if amount and amount >= 10
                res.validationError fields: [
                    path: 'teamId'
                    message: 'L\'équipe a atteint la limite de joueurs'
                ]
                return
            # hash the password
            bcrypt.hash req.body.password, 8, (err, hash) ->
                req.body.password = hash
                # now try to build the entity
                res.buildModelOrFail User, req.body, (user) ->
                    # now, refresh data (for more coherent types in API responses)
                    selectUserFromReq user.id, req, (user) ->
                        res.status 201
                        res.set 'Location', res.url 'users.get', id: user.id
                        res.json formatUser(user)
        .catch (err) ->
            res.validationError fields: [
                path: 'teamId'
                message: err
            ]
            return



# METHODS
# -------

formatUser = (user) ->
    result = user
    delete result.dataValues.password
    return result

selectUserFromReq = (id, req, callback) ->
    User.findOne
        where: id: id
        include: req.getAssocSections ['team']
    .done callback
