# SETTING COLLECTIONS
# -------------------

module.exports = (app) ->
    users = require './users'
    users app

#teams = require './teams'
#router.use '/teams', teams
