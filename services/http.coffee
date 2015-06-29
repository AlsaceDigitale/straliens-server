# modules
_ = require 'underscore'
expressSession = require 'express-session'
sharedSession = require 'express-socket.io-session'
Router = require 'named-routes'
cors = require 'cors'
bodyParser = require 'body-parser'
# config
net = require '../config/networking'


# configure session for express + socket.io
addSession = (app, io) ->
    session = expressSession
        secret: net.http.cookieSecret
        resave: true
        saveUninitialized: true

    app.use session
    io.use sharedSession(session)

# enable middlewares
addThirdPartyMiddlewares = (app) ->
    app.use cors()
    app.use bodyParser.urlencoded extended: true
    # extend express and routing
    router = new Router
    router.extendExpress app
    router.registerAppHelpers app

# add some methods on responses
tuneResponses = (app) ->
    app.use (req, res, next) ->
        # returns a sequelize table to include
        # model associations in REST
        req.getAssocSections = (availableSections) ->
            return if not req.query.sections? # if no section is specified
            sections = req.query.sections.split ','
            includes = []
            includes.push {
                model: require "../models/#{section}"
                as: section
            } for section in availableSections when section in sections
            return includes

        # builds URL from toute name and route params
        res.url = (route, params) ->
            app.namedRoutes.build route, params

        # 'model' is a sequelize schema
        res.findOrFail = (model, id, callback) ->
            model.findById id
                .then (entity) ->
                    if entity is null
                        res.status 404
                    else
                        callback entity

        # instantiates a model from an object
        # or fail with Bad Request
        res.buildModelOrFail = (model, datas, callback) ->
            entity = model.build datas
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
    addSession: addSession
    addThirdPartyMiddlewares: addThirdPartyMiddlewares
    tuneResponses: tuneResponses
