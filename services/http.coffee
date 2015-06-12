# modules
cors = require 'cors'
bodyParser = require 'body-parser'


# enable middlewares
addThirdPartyMiddlewares = (app) ->
    app.use cors()
    app.use bodyParser.urlencoded extended: true

# add some methods on responses
tuneResponses = (app) ->
    app.use (req, res, next) ->
        # 'model' is a sequelize schema
        res.findOrFail = (model, id, callback) ->
            model.findById id
                .then (entity) ->
                    if entity is null
                        res.status 404
                    else
                        callback entity

        # instantiates a model from an urlencoded form
        # or fail with Bad Request
        res.modelFromFormOrFail = (model, callback) ->
            entity = model.build req.body
            entity.validate().then (problem) ->
                if !problem
                    entity.save().then -> callback entity
                else
                    errorslist = []
                    errorslist.push {
                        path: error.path
                        message: error.message
                    } for error in problem.errors

                    res.status 400
                    res.json
                        type: 'ValidationError'
                        fields: errorslist

        do next


# export
module.exports =
    addThirdPartyMiddlewares: addThirdPartyMiddlewares
    tuneResponses: tuneResponses