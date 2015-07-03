exec = require('child_process').exec
module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    grunt.registerInitTask 'resources', 'Copy resources in the build folder', ->
        exec "cp -r static/web/resources static/web/build", (error, stdout, stderr) ->
            grunt.log.writeln 'stdout: ' + stdout
            grunt.log.writeln 'stderr: ' + stderr
            if error
                grunt.log.writeln error


    grunt.initConfig
        # COFFEE COMPILATION
        coffee: compile:
            options: join: true
            files: 'static/web/build/js/app.js': ['static/web/coffee/**/*.coffee']

        # SASS COMPILATION
        sass: compile:
            options: style: 'compressed'
            files: [
                cwd: 'static/web/sass'
                src: ['**/*.sass', '**/*.scss']
                dest: 'static/web/build/css'
                expand: true
                ext: '.min.css'
            ]

        # JADE COMPILATION
        jade: compile:
            options:
                client: false
                pretty: false
            files: [
                cwd: 'static/web/jade'
                src: '**/*.jade'
                dest: 'static/web/build'
                expand: true
                ext: '.html'
            ]

        # WATCH FILES AND COMPILE ON CHANGE
        # Posix: `grunt watch &`
        # Windows: `START /B grunt watch`
        watch:
            coffee:
                files: ['static/web/coffee/**/*.coffee']
                tasks: ['coffee']
            jade:
                files: ['static/web/jade/**/*.jade']
                tasks: ['jade']
            sass:
                files: ['static/web/sass/**/*.sass', 'static/web/sass/**/*.scss']
                tasks: ['sass']

    # Basic tasks calling other tasks
    # -------------------------------

    grunt.registerTask 'default', ['jade', 'sass', 'coffee', 'resources']


    # More complex tasks
    # ------------------

    # empty
