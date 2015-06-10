# modules
express = require 'express'
router = express.Router()
User = require '../models/user'

# ENDPOINTS
# ---------

# GET /api/users
router.get '/', (req, res) ->
    res.json []


# GET /api/users/:id
router.get '/:id', (req, res) ->
    res.findOrFail User, req.params.id, (user) ->
        res.json formatUser user


# METHODS
# -------

formatUser = (user) ->
    result = user
    return result


# export routing
module.exports = router
