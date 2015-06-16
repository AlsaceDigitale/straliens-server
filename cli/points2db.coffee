# modules
colors = require 'colors'
logger = require '../services/logger'
db = require '../models/db'
request = require 'request'
Point = require '../models/point'
# config
net = require '../config/networking'
# points data
pointDatas = require '../resources/points.json'


# BEGIN
# ------

createPointFn = (name, address, lat, lng) ->
    Point.create
        name: name
        address: address
        lat: lat
        lng: lng

Point.drop().then -> db.syncSchemas ->
    for point in pointDatas.points
        point.name or= 'Unnamed Point'
        [lng, lat] = point.coordinates
        geocodeUrl = net.google.geocodeUrlFn lat, lng, net.google.apikey

        # is address defined?
        if point.address
            createPointFn point.name, point.address, lat, lng
            continue

        # reverse geocoding using google
        request geocodeUrl, (err, res, body) ->
            logger.info "importing point \"#{point.name}\"".underline
            logger.info " -> reverse geocoding: code #{res.statusCode}"

            # an error occured
            if res.statusCode isnt 200
                logger.error "    API ERROR #{res.statusCode}".red
                return

            # no error - parsing results
            body = JSON.parse body
            if not body.results.length
                address = 'Undefined Address'
                logger.info '    NO ADDRESS FOUND'.red
            else
                address = body.results[0].formatted_address
                logger.info "    #{address}"

            # save point in db
            createPointFn point.name, address, lat, lng
