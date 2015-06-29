module.exports =
    sql:
        database: 'straliens'
        username: 'root'
        password: 'rootrootroot'
        host: 'root.c3dgxuvof2mc.eu-west-1.rds.amazonaws.com'
    http:
        port: process.env.PORT || 3000
        cookieSecret: '~4NaTWbY67!~'
    google:
        apikey: 'AIzaSyDDttlqIKKSDwCO0iMiHgEqrAA6UynjoXQ'
        geocodeUrlFn: (lat, lng, key) -> "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}&key=#{key}"
        geocodeDelay: 200