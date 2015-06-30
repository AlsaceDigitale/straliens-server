# modules
Team = require '../models/team'


# CONTROLLER
# ----------
module.exports = (app) ->

    # GET /api/teams
    app.get '/api/teams/', 'teams.list', (req, res) ->
        list = []
        Team.findAll().then (teams) ->
            list.push formatTeam(team) for team in teams
            res.json list

    # GET /api/teams/:id
    app.get '/api/teams/:id', 'teams.get', (req, res) ->
        res.findOrFail Team, req.params.id, (team) ->
            res.json formatTeam(team)

    # POST /api/teams
    app.post '/api/teams/', 'teams.post', (req, res) ->
        res.buildModelOrFail Team, req.body, (team) ->
            res.json formatTeam(team)


# METHODS
# -------

formatTeam = (team) ->
    result = team
    delete result.dataValues.password
    return result
