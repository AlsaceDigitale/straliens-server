tuneResponses = (app) ->
    # add a findOrFail method on responses
    # 'model' is an ORM schema
    app.use (req, res, next) ->
        res.findOrFail = (model, id, callback) ->
            model.findById id
                .then (entity) ->
                    if entity is null
                        res.json 404
                    else
                        callback entity
        do next


# export
module.exports =
    tuneResponses: tuneResponses