# modules
express = require 'express'
router = express.Router()

# ENDPOINTS
# ---------

# GET /api/users
router.get '/', (req, res) ->
    res.json []


# GET /api/users/:id
router.get '/:id', (req, res) ->
    res.json id: req.params.id


# export routing
module.exports = router
