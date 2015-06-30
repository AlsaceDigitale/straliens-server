module.exports =
    sql:
        db_url: process.env.SCALINGO_MYSQL_URL || 'mysql://straliens:stralienspa$$@localhost/straliens'
    http:
        port: process.env.PORT || 3000
        cookieSecret: '~4NaTWbY67!~'
    google:
        apikey: 'AIzaSyDDttlqIKKSDwCO0iMiHgEqrAA6UynjoXQ'
        geocodeUrlFn: (lat, lng, key) -> "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}&key=#{key}"
        geocodeDelay: 200