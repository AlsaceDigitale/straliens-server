module.exports = function(grunt) {

    grunt.initConfig({
        sass: {
            compile: {
                options: {
                    style: "compressed"
                },
                files: [{
                    cwd: "public",
                    src: "**/*.sass",
                    dest: "public",
                    expand: true,
                    ext: ".css"
                }]
            }
        },
        jade: {
            compile: {
                options: {
                    client: false,
                    pretty: false
                },
                files: [{
                    cwd: "public",
                    src: "**/*.jade",
                    dest: "public",
                    expand: true,
                    ext: ".html"
                }]
            }
        }
    });

    grunt.loadNpmTasks('grunt-contrib-jade');
    grunt.loadNpmTasks('grunt-contrib-sass');

    grunt.registerTask('default', ['jade', 'sass']);

};