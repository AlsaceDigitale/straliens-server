###################################################
## OBSOLETE AND DEAD CODE DUE TO CHANGES IN ARCH ##
###################################################

# modules
express = require 'express'
router = express.Router()
Team = require '../models/team'

# ENDPOINTS
# ---------

# GET /api/teams
router.get '/', (req, res) ->
    list = []
    Team.findAll().then (teams) ->
        list.push formatTeam(team) for team in teams
        res.json list


# GET /api/teams/:id
router.get '/:id', (req, res) ->
    res.findOrFail Team, req.params.id, (team) ->
        res.json formatTeam(team)

# POST /api/teams
router.post '/', (req, res) ->
    res.modelFromFormOrFail Team, (team) ->
        res.json team


# METHODS
# -------

formatTeam = (team) ->
    result = team
    return result


# export routing
module.exports = router
