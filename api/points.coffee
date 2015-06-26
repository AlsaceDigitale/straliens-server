# modules
Points = require '../models/point'
User = require '../models/user'
Team = require '../models/team'


# CONTROLLER
# ----------
module.exports = (app) ->

    # GET /api/points/:id/check
    app.get '/api/points/:id/check', (req, res) ->
        list = []
        Points.findOne
            where: id: req.params.id
        .done (point) -> res.json point




# METHODS
# -------

formatPoint = (point) ->
    result = point
    return result

selectUserFromReq = (id, req, callback) ->
    User.findOne
        where: id: id
        include: req.getAssocSections ['team']
    .done callback
