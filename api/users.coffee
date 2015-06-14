# modules
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
        res.modelFromFormOrFail User, (user) ->
            # now, refresh data (for more coherent types in API responses)
            selectUserFromReq user.id, req, (user) ->
                res.status 201
                res.set 'Location', res.url 'users.get', id: user.id
                res.json user


# METHODS
# -------

formatUser = (user) ->
    result = user
    return result

selectUserFromReq = (id, req, callback) ->
    User.findOne
        where: id: id
        include: req.getAssocSections ['team']
    .done callback
