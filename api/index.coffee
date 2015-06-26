# SETTING COLLECTIONS
# -------------------

module.exports = (app) ->
    users = require './users'
    users app

    points = require './points'
    points app

# utiliser l'app en parametre et pas un router
#    teams = require './teams'
#    teams app

# à deprecate
#teams = require './teams'
#router.use '/teams', teams
