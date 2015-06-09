# modules
express = require 'express'
router = express.Router()

# SETTING COLLECTIONS
# -------------------

users = require './users'
router.use '/users', users


# export routing
module.exports = router;