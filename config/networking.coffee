module.exports =
    sql:
        database: process.env.DB_NAME || 'straliens'
        username: process.env.DB_USER || 'straliens'
        password: process.env.DB_PASS || 'stralienspa$$'      
        host: process.env.DB_HOST || 'localhost'
    http:
        port: process.env.PORT || 3000
        cookieSecret: '~4NaTWbY67!~'
    google:
        apikey: 'AIzaSyDDttlqIKKSDwCO0iMiHgEqrAA6UynjoXQ'
        geocodeUrlFn: (lat, lng, key) -> "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}&key=#{key}"
        geocodeDelay: 200