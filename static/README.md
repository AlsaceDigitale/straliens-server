# straliens-server

## Frontend

### Requirements

 - NodeJS
 - Grunt (`npm install -g grunt-cli`)
 - Ruby (needed for SASS compilation)

### Deployment

 - `npm install` to install Node dependencies
 - `grunt` to compile CoffeeScript, SASS and Jade into JS, CSS and HTML. This is needed the first time, then you can use the following command:
 - `grunt watch` to watch for changes into Coffee/SASS/Jade sources and compile them on-the-fly.
   - On Linux, start in async with `grunt watch &`
   - On Windows, start in async with `START /B grunt watch`

### Serve files over HTTP

You can't just open the index.html in your browser *via* `file://`. A webserver is needed since the page loads scripts from other domains, which is impossible in static browsing, due to increased CORS restrictions.

Until we get a backend server, you could do this...
 - Install PHP CLI : `sudo apt-get install php5-cli`
 - `cd web/build`
 - `php -S localhost:8000`
 - Open `localhost:8000` in your browser.
