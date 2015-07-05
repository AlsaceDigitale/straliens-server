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
    app.use cors
        credentials: true
        origin: [/straliens\.eu/, /localhost:.*/, /straliens-staging\.scalingo\.io/]
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

        # checks if a user is authenticated
        # otherwise, throw a 403 error
        req.checkAuthentication = ->
            unless req.session.user
                do res.pleaseLoginError
                return false
            else
                return true

        # builds URL from route name and route params
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
                type: type
                message: message
            }, additionalData

        res.notFoundError = (message, additionalData = {}) ->
            message or= 'Vous avez demandé une ressource inexistante.'
            res.genericError message, 'NotFoundError', 404, additionalData

        res.accessDeniedError = (message, additionalData = {}) ->
            message or= 'Accès refusé: vous n\'avez pas les droits suffisants pour accéder à cette fonctionnalité.'
            res.genericError message, 'AccessDeniedError', 403, additionalData

        res.pleaseLoginError = (message, additionalData = {}) ->
            message or= 'Accès refusé: vous devez vous connecter pour avoir accès à cette fonctionnalité'
            res.genericError message, 'AccessDeniedError', 401, additionalData

        res.validationError = (errors) ->
            res.genericError 'Le formulaire comporte des champs erronés.', 'ValidationError', 400, errors

        do next

# export
module.exports =
    addSession: addSession
    addThirdPartyMiddlewares: addThirdPartyMiddlewares
    tuneResponses: tuneResponses
