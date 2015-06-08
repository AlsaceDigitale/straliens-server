module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-jade'
    grunt.loadNpmTasks 'grunt-contrib-sass'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    grunt.initConfig

        sass: compile:
            options: style: 'compressed'
            files: [
                cwd: 'web/sass'
                src: '**/*.sass'
                dest: 'web/build/css'
                expand: true
                ext: '.min.css'
            ]

        jade: compile:
            options:
                client: false
                pretty: false
            files: [
                cwd: 'web/jade'
                src: '**/*.jade'
                dest: 'web/build'
                expand: true
                ext: '.html'
            ]

        watch:
            coffee:
                files: ['web/jade/**/*.jade']
                tasks: ['jade']
            sass:
                files: ['web/sass/**/*.sass']
                tasks: ['sass']

    # Basic tasks calling other tasks
    # -------------------------------

    grunt.registerTask 'default', ['jade', 'sass']


    # More complex tasks
    # ------------------

    # empty
