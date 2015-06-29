module.exports =
    sql:
        database: 'straliens'
        username: 'straliens'
        password: 'stralienspa$$'
    http:
        port: process.env.PORT || 3000
        cookieSecret: '~4NaTWbY67!~'
    google:
        apikey: 'AIzaSyDDttlqIKKSDwCO0iMiHgEqrAA6UynjoXQ'
        geocodeUrlFn: (lat, lng, key) -> "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}&key=#{key}"
        geocodeDelay: 200