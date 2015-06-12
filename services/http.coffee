# modules
_ = require 'underscore'
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

                    res.validationError fields: errorslist

        # helpers for returning errors
        res.genericError = (message, type = 'GenericError', code = 400, additionalData = {}) ->
            res.status code
            res.json _.extend {
                success: false
                status: code
                message: message
            }, additionalData

        res.notFoundError = (message, additionalData = {}) ->
            message or= 'Your request asked for a an non-existent resource.'
            res.genericError message, 'NotFoundError', 404, additionalData

        res.accessDeniedError = (message, additionalData = {}) ->
            message or= 'Access denied: you have no sufficient credentials to access this feature.'
            res.genericError message, 'AccessDeniedError', 403, additionalData

        res.pleaseLoginError = (message, additionalData = {}) ->
            message or= 'Access denied: please log in to access this feature.'
            res.genericError message, 'AccessDeniedError', 403, additionalData

        res.validationError = (errors) ->
            res.genericError 'The form has erroneous fields!', 'ValidationError', 400, errors

        do next

# export
module.exports =
    addThirdPartyMiddlewares: addThirdPartyMiddlewares
    tuneResponses: tuneResponses