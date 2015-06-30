# SETTING COLLECTIONS
# -------------------

module.exports = (app) ->
    services = require './services'
    services app

    users = require './users'
    users app

    teams = require './teams'
    teams app

    points = require './points'
    points app

    games = require './games'
    games app

# utiliser l'app en parametre et pas un router
#    teams = require './teams'
#    teams app

# à deprecate
#teams = require './teams'
#router.use '/teams', teams
