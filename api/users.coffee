# modules
express = require 'express'
router = express.Router()
db = require '../models/db'
User = require '../models/user'

# ENDPOINTS
# ---------

# GET /api/users
router.get '/', (req, res) ->
    list = []
    User.findAll().then (users) ->
        list.push formatUser(user) for user in users
        res.json list


# GET /api/users/:id
router.get '/:id', (req, res) ->
    res.findOrFail User, req.params.id, (user) ->
        res.json formatUser(user)

# POST /api/users
router.post '/', (req, res) ->
    res.modelFromFormOrFail User, (user) ->
        res.json user


# METHODS
# -------

formatUser = (user) ->
    result = user
    return result


# export routing
module.exports = router
